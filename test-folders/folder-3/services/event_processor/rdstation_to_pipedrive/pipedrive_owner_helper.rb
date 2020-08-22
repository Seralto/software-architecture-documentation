module EventProcessor
  class RdstationToPipedrive
    class PipedriveOwnerHelper
      def initialize(event_payload, authorization)
        @event_payload = event_payload
        @authorization = authorization
      end

      def find_owner_id
        find_payload_owner_id || find_account_owner_id
      end

      private

      def find_payload_owner_id
        contact_owner_email = @event_payload.dig('contact', 'funnel', 'contact_owner_email')
        return if contact_owner_email.blank?

        response = pipedrive_client.by_email contact_owner_email
        return if not_a_valid_response(response)

        response['data'].first['id']
      end

      def find_account_owner_id
        response = pipedrive_client.me
        return if not_a_valid_response(response)

        response.dig('data', 'id')
      end

      def not_a_valid_response(response)
        response.blank? || !response['success'] || response['data'].blank?
      end

      def pipedrive_client
        @pipedrive_client ||= Pipedrive::Users.new(@authorization)
      end
    end
  end
end
