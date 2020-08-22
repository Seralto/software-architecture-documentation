module Migration
  class PipedriveTriggersService
    def initialize(account)
      @account = account
    end

    def create_won_rule
      RuleService.new(
        event_id: Event.deal_won.id,
        filters: {},
        actions_params: [{ 'stages' => [], 'event_id' => Event.mark_as_sale.id }],
        name: I18n.t('migrations.deal_won'),
        integration_id: account_integration_by_type.id,
      ).create
    end

    def create_lost_rule
      RuleService.new(
        event_id: Event.deal_lost.id,
        filters: {},
        actions_params: [{ 'stages' => [], 'event_id' => Event.opportunity_lost.id }],
        name: I18n.t('migrations.deal_lost'),
        integration_id: account_integration_by_type.id,
      ).create
    end

    def won_lost_enabled_in_rdsm_integration?
      Pipedrive::Webhooks.new(@account.authorizations.pipedrive.take).all.select do |webhook|
        webhook['subscription_url'] =~ %r{https://.{3}\.rdstation\.com\.br/api/1\.2/services/.+/pipedrive}
      end.any?
    end

    private

    def account_integration_by_type
      @account_integration_by_type ||= @account.integrations.find_by(type: 'pipedrive_to_rdstation')
    end
  end
end
