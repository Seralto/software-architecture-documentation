module EventListener
  class PipedriveEvent
    attr_reader :event_type_identifier, :entity_type_identifier

    def initialize(event_identifier)
      @event_type_identifier, @entity_type_identifier = event_identifier.values_at('event_type', 'entity_type')
    end

    def event_id
      return unless event

      event.id
    end

    private

    def event
      @event ||= Event.trigger.find_by(entity_type: entity_type, event_type: event_type)
    end

    def event_type
      @event_type ||= EventType.find_by(pipedrive_identifier: event_type_identifier)
    end

    def entity_type
      @entity_type ||= EntityType.find_by(pipedrive_identifier: entity_type_identifier)
    end
  end
end
