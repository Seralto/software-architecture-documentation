module EventParser
  class Pipedrive
    class WonDeal
      WON_STATUS = 'won'.freeze
      EVENT_IDENTIFIER = 'won.deal'.freeze

      def initialize(event_payload)
        @event_payload = event_payload
      end

      def event_identifier
        return unless deal_won?

        EVENT_IDENTIFIER
      end

      private

      def deal_won?
        deal_status.changed? && deal_status.match?(WON_STATUS)
      end

      def deal_status
        @deal_status ||= DealStatus.new(@event_payload)
      end
    end
  end
end
