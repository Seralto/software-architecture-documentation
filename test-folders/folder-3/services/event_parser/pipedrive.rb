module EventParser
  class Pipedrive
    PARSERS = [
      LostDeal,
      WonDeal,
    ].freeze

    def initialize(event_payload)
      @event_payload = event_payload
    end

    def all
      PARSERS.map { |parser| parser.new(@event_payload) }
    end
  end
end
