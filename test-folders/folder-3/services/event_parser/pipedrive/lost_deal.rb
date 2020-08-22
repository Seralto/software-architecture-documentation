module EventParser
  class Pipedrive
    class LostDeal
      LOST_STATUS = 'lost'.freeze
      EVENT_IDENTIFIER = 'lost.deal'.freeze

      def initialize(event_payload)
        @event_payload = event_payload
      end

      def event_identifier
        return unless deal_lost?

        EVENT_IDENTIFIER
      end

      private

      def deal_lost?
        deal_status.changed? && deal_status.match?(LOST_STATUS)
      end

      def deal_status
        @deal_status ||= DealStatus.new(@event_payload)
      end
    end
  end
end
