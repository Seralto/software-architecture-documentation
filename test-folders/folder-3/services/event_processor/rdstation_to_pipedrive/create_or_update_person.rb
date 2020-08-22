module EventProcessor
  class RdstationToPipedrive
    class CreateOrUpdatePerson
      include Comparable
      include ::PipedriveAppLogger
      include EventProcessor::RequestLogger

      EVENT_TYPE = 'CREATE_PERSON'.freeze

      def initialize(account_id, field_combination, event_payload)
        @account_id = account_id
        @field_combination = field_combination
        @event_payload = event_payload
      end

      def process(state_chain = {})
        person_payload = process_payload(state_chain)
        log_event_processing(person_payload)
        create_or_update(person_payload)
      end

      private

      def process_payload(state_chain)
        related_entities_params = related_entities_params(state_chain)
        person_payload = payload.merge(related_entities_params)
        person_payload['owner_id'] = PipedriveOwnerHelper.new(@event_payload, authorization).find_owner_id
        person_payload.compact
      end

      def related_entities_params(state_chain)
        {
          'org_id' => state_chain[:organization_id],
          'person_id' => state_chain[:person_id],
        }.compact
      end

      def create_or_update(person_payload)
        existing_person_id = find_person_id_by_email
        log_info(account_id: @account_id, existing_person_id: existing_person_id, complete_payload: person_payload)
        return update(existing_person_id, person_payload) if existing_person_id

        create(person_payload)
      end

      def find_person_id_by_email
        email = payload['email']
        response = persons_client.by_email(email)
        log_info(msg: 'find_person_id_by_email', response: response)
        response['data'].first['id'] if response['success'] && response['data'].present?
      end

      def create(person_payload)
        response = persons_client.create(person_payload)
        handle_response(response)
      end

      def update(id, person_payload)
        response = persons_client.update(id, person_payload)
        handle_response(response)
      end

      def handle_response(response)
        if response['success']
          log_response_success(response)
          return { person_id: response['data']['id'] }
        end

        log_response_error(response)
        {}
      end

      def persons_client
        Pipedrive::Persons.new(authorization)
      end

      def authorization
        @authorization ||= AuthorizationPipedrive.find_by(account_id: @account_id)
      end

      def payload
        @payload ||= @field_combination.map_values_for_pipedrive(
          entity_type: 'person',
          entity_payload: contact,
        )
      end

      def contact
        @contact ||= @event_payload['contact']
      end

      def <=>(other)
        return +1 if other.is_a?(CreateOrUpdateOrganization)
        return -1 if other.is_a?(CreateDeal)

        0
      end
    end
  end
end
