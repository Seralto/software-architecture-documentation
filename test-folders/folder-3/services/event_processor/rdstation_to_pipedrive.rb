module EventProcessor
  class RdstationToPipedrive
    def initialize(account, action_events, payload, actions_rules = [])
      @account = account
      @action_events = action_events
      @payload = payload
      @actions_rules = actions_rules
    end

    def events
      action_events.map do |action_event|
        entity_type = action_event.entity_type.pipedrive_identifier
        event_type = action_event.event_type.pipedrive_identifier

        event = "#{event_type}.#{entity_type}"

        case event
        when 'create.organization'
          CreateOrUpdateOrganization.new(account.id, field_combination, payload)
        when 'create.person'
          CreateOrUpdatePerson.new(account.id, field_combination, payload)
        when 'create.deal'
          # TODO: Change this implementation in order to create the deal in Pipedrive
          #       with the correct stage_id based on the new implementation
          CreateDeal.new(account.id, field_combination, payload, stages(action_event))
        end
      end.sort
    end

    private

    attr_reader :account, :action_events, :payload, :actions_rules

    def field_combination
      @field_combination ||= account.field_combination
    end

    def stages(action_event)
      actions_rules.select { |actions_rule| actions_rule.action.event == action_event }.first.stages
    end
  end
end
