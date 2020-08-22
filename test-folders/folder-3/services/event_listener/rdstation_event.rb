module EventListener
  class RdstationEvent
    attr_reader :event_payload

    def initialize(event_payload)
      @event_payload = event_payload
    end

    def event_id
      return unless event

      event.id
    end

    private

    def event
      @event ||= Event.find_by(entity_type: entity_type, event_type: event_type)
    end

    def event_type
      @event_type ||= EventType.find_by(rd_identifier: event_payload['event_type'])
    end

    def entity_type
      @entity_type ||= EntityType.find_by(rd_identifier: event_payload['entity_type']&.downcase)
    end
  end
end
