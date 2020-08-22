module EventProcessor
  class PipedriveToRdstation
    class PipedriveEvents
      include ::PipedriveAppLogger

      EVENT_FAMILY = 'CDP'.freeze

      def initialize(account_id, field_combination, event_payload)
        @account_id = account_id
        @field_combination = field_combination
        @event_payload = event_payload
      end

      def process(_state_chain = {})
        log_event_processing
        event_payload = payload
        return {} unless event_payload.dig('payload', 'email')

        events.create(event_payload)
      rescue RDStation::Error => error
        log_event_error(error)
        EventProcessor::ErrorHandling.retry(error.details[:http_status])
      end

      private

      def log_event_processing
        log_info(
          event_type: self.class::EVENT_TYPE,
          status: Event::Status::PROCESSING,
          account_id: @account_id,
          field_combination: @field_combination,
          event_payload: payload,
        )
      end

      def log_event_error(error)
        log_error(
          event_type: self.class::EVENT_TYPE,
          status: Event::Status::ERROR,
          account_id: @account_id,
          field_combination: @field_combination,
          event_payload: payload,
          error: error,
        )
      end

      def payload
        {
          'event_type' => self.class::EVENT_TYPE,
          'event_family' => EVENT_FAMILY,
          'payload' => fixed_fields.merge(mapped_fields),
        }
      end

      def mapped_fields
        @mapped_fields ||= @field_combination.map_values_for_rdstation(
          entity_type: 'deal',
          entity_payload: current_entity,
        )
      end

      def current_entity
        @current_entity ||= @event_payload['current']
      end

      def events
        RdstationClient::Events.new(authorization_rdstation)
      end

      def person
        person_id = current_entity['person_id']
        return {} unless person_id

        pipedrive_persons.by_id(person_id)
      end

      def pipedrive_persons
        Pipedrive::Persons.new(authorization_pipedrive)
      end

      def person_email
        person_emails = person.dig('data', 'email')
        return if person_emails.blank?

        person_emails.first['value']
      end

      def authorization_rdstation
        @authorization_rdstation ||= AuthorizationRdstation.find_by(account_id: @account_id)
      end

      def authorization_pipedrive
        @authorization_pipedrive ||= AuthorizationPipedrive.find_by(account_id: @account_id)
      end
    end
  end
end
