module EventProcessor
  class PipedriveToRdstation
    class CreateOrUpdateContact
      include ::PipedriveAppLogger

      def initialize(account_id, field_combination, event_payload)
        @account_id = account_id
        @field_combination = field_combination
        @event_payload = event_payload
      end

      def process(_state_chain = {})
        log_event_processing
        email_value = payload.delete('email')
        contacts.upsert('email', email_value, payload)
      rescue RDStation::Error => error
        EventProcessor::ErrorHandling.retry(error.details[:http_status])
      end

      private

      def log_event_processing
        log_info(
          event_type: EVENT_TYPE,
          status: Event::Status::PROCESSING,
          account_id: @account_id,
          field_combination: @field_combination,
          event_payload: payload,
        )
      end

      def authorization
        @authorization ||= AuthorizationRdstation.find_by(account_id: @account_id)
      end

      def contacts
        RdstationClient::Contacts.new(authorization)
      end

      def payload
        @payload ||= @field_combination.map_values_for_rdstation(
          entity_type: 'person',
          entity_payload: current_entity,
        )
      end

      def current_entity
        @current_entity ||= @event_payload['current']
      end
    end
  end
end
