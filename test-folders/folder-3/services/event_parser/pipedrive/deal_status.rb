module EventParser
  class Pipedrive
    class DealStatus
      def initialize(event_payload)
        @event_payload = event_payload
      end

      def match?(status)
        current_status == status
      end

      def changed?
        current_status != previous_status
      end

      private

      attr_reader :event_payload

      def current_status
        @current_status ||= event_payload.dig('current', 'status')
      end

      def previous_status
        @previous_status ||= event_payload.dig('previous', 'status')
      end
    end
  end
end
