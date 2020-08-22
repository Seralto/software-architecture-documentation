module EventProcessor
  class PipedriveToRdstation
    ACTIONS = {
      'update.contact' => CreateOrUpdateContact,
      'lost.deal' => OpportunityLost,
      'sale.deal' => Sale,
    }.freeze

    def initialize(account, action_events, payload)
      @account = account
      @action_events = action_events
      @payload = payload
    end

    def events
      action_events.map do |action_event|
        entity_type = action_event.entity_type.rd_identifier
        event_type = action_event.event_type.rd_identifier
        event = "#{event_type}.#{entity_type}"
        action_for(event)
      end
    end

    private

    attr_reader :account, :action_events, :payload

    def action_for(event)
      action = ACTIONS[event]
      return unless action

      action.new(account.id, field_combination, payload)
    end

    def field_combination
      @field_combination ||= account.field_combination
    end
  end
end
