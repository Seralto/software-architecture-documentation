module Migration
  class MigratorService
    RDSTATION_TO_PIPEDRIVE = 'rdstation_to_pipedrive'.freeze
    EVENT_TYPE_MAPPING = {
      'NotificationEventLeadConversion' => 'conversion',
      'NotificationEventLeadOpportunity' => 'marked_as_opportunity',
    }.freeze

    def initialize(platform_account_id)
      @platform_account_id = platform_account_id
      @data = integration_data
    end

    def perform
      check_data_errors
      ActiveRecord::Base.transaction do
        save_fields_combination
        save_rule
        create_rdstation_webhook
        create_won_and_lost_rule if won_lost_enabled_in_rdsm_integration?
        mark_accout_as_migrated

        raise ActiveRecord::Rollback unless stop_enqueuing_old_integration
      end
    rescue InvalidData => error
      raise error
    end

    private

    def context
      Mstk::Context.create(account.id, platform_account_id: @platform_account_id)
    end

    def integration_data
      client.by_account(context, @platform_account_id)
    end

    def client
      RdstationInternal::PipedriveNotifications.new
    end

    def check_data_errors
      return unless @data['errors']

      raise InvalidData.new, @data['errors']
    end

    def save_fields_combination
      field_combination = FieldCombination.find_by(account_id: account.id)
      new_field_combination = fields_combination_parser(@data['custom_fields'])
      field_combination.mapping.deep_merge!(new_field_combination)
      field_combination.save
    end

    def account
      @account ||= Account.find_by(platform_account_id: @platform_account_id)
    end

    def save_rule
      RuleService.new(
        name: rule_title,
        integration_id: account.integrations.rdstation_to_pipedrive.take.id,
        event_id: rdsm_trigger_event.id,
        actions_params: actions_params,
        filters: filters,
      ).create
    end

    def create_rdstation_webhook
      WebhookRegistrationService.register(
        account_id: account.id,
        integration: account.integrations.rdstation_to_pipedrive.take,
        event_type: rdsm_trigger_event.event_type,
      )
    end

    def stop_enqueuing_old_integration
      client.skip_enqueue(context, @platform_account_id)
    end

    def create_won_and_lost_rule
      pipedrive_trigger_service.create_won_rule
      pipedrive_trigger_service.create_lost_rule
      create_pipedrive_webhook
    end

    def create_pipedrive_webhook
      WebhookRegistrationService.register(
        account_id: account.id,
        integration: account.integrations.pipedrive_to_rdstation.take,
        event_type: nil, # it doesn't matter for Pipedrive
      )
    end

    def won_lost_enabled_in_rdsm_integration?
      pipedrive_trigger_service.won_lost_enabled_in_rdsm_integration?
    end

    def pipedrive_trigger_service
      @pipedrive_trigger_service ||= PipedriveTriggersService.new(account)
    end

    def mark_accout_as_migrated
      account.migrated = true
      account.save!
    end

    def rdsm_trigger_event
      Event.find_by(description: EVENT_TYPE_MAPPING[@data['hook_event']], category: 'trigger')
    end

    def actions_params
      actions_events = Event.where(integration_type: RDSTATION_TO_PIPEDRIVE, category: 'action')
      actions_events = remove_deal_creation(actions_events) unless @data['funnel_stages']
      actions_events.map { |action_event| { 'event_id' => action_event.id, 'stages' => stages(action_event) } }
    end

    def remove_deal_creation(actions_events)
      actions_events.reject { |actions_event| actions_event.description == 'create_deal_in_pipedrive' }
    end

    def stages(event)
      return [] unless @data['funnel_stages'] && event.description == 'create_deal_in_pipedrive'

      stages_parser(@data['funnel_stages'])
    end

    def filters
      { 'conversion_identifier' => @data['conversion_identifiers'] }
    end

    def rule_title
      return I18n.t('migrations.convertion') if EVENT_TYPE_MAPPING[@data['hook_event']] == 'conversion'

      I18n.t('migrations.marked_as_opportunity')
    end

    def fields_combination_parser(field_combination)
      Migration::ParserService.parse_fields_combination(field_combination)
    end

    def stages_parser(stages)
      Migration::ParserService.parse_stages(stages)
    end
  end

  class InvalidData < StandardError; end
end
