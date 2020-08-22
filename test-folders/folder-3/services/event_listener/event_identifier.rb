module EventListener
  class EventIdentifier
    def initialize(event_parsers)
      @event_parsers = event_parsers
    end

    def to_hash
      event_type, entity_type = to_s.split('.')

      {
        'event_type' => event_type,
        'entity_type' => entity_type,
      }.compact
    end

    private

    def to_s
      @to_s ||= event_parsers.map(&:event_identifier).find(&:present?).to_s
    end

    attr_reader :event_parsers
  end
end
