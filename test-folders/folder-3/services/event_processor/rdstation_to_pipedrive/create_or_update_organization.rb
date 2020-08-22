module EventProcessor
  class RdstationToPipedrive
    class CreateOrUpdateOrganization
      include Comparable
      include ::PipedriveAppLogger
      include EventProcessor::RequestLogger

      EVENT_TYPE = 'CREATE_ORGANIZATION'.freeze

      def initialize(account_id, field_combination, event_payload)
        @account_id = account_id
        @field_combination = field_combination
        @event_payload = event_payload
      end

      def process(_state_chain = {})
        organization_payload = process_payload
        log_event_processing(organization_payload)
        create_or_update(organization_payload)
      end

      private

      def process_payload
        organization_payload = payload
        organization_payload['name'] = organization_name if organization_payload['name'].blank?
        organization_payload['owner_id'] = PipedriveOwnerHelper.new(@event_payload, authorization).find_owner_id
        organization_payload.compact
      end

      def organization_name
        campany_name = contact.dig('company', 'name')
        return campany_name unless campany_name.blank?

        contact['name']
      end

      def create_or_update(payload)
        existing_organization_id = find_organization_id_by_name
        log_info(account_id: @account_id, existing_organization_id: existing_organization_id, complete_payload: payload)
        return update(existing_organization_id, payload) if existing_organization_id

        create(payload)
      end

      def find_organization_id_by_name
        name = payload['name']
        response = organizations_client.by_name(name)
        log_info(msg: 'find_organization_id_by_name', response: response)
        return unless response['success'] && response['data'].present?

        organization = match_organization(response['data'], name)
        organization['id'] if organization
      end

      def match_organization(organizations, name)
        organizations.find { |org| downcase_without_spaces(org['name']) == downcase_without_spaces(name) }
      end

      def downcase_without_spaces(string)
        string.delete(' ').downcase
      end

      def update(id, payload)
        response = organizations_client.update(id, payload)
        handle_response(response)
      end

      def create(payload)
        response = organizations_client.create(payload)
        handle_response(response)
      end

      def handle_response(response)
        if response['success']
          log_response_success(response)
          return { organization_id: response['data']['id'] }
        end

        log_response_error(response)
        {}
      end

      def organizations_client
        Pipedrive::Organizations.new(authorization)
      end

      def authorization
        @authorization ||= AuthorizationPipedrive.find_by(account_id: @account_id)
      end

      def payload
        @payload ||= @field_combination.map_values_for_pipedrive(
          entity_type: 'organization',
          entity_payload: @event_payload['contact'].with_indifferent_access,
        )
      end

      def organization
        @organization ||= @event_payload['contact']['company'].with_indifferent_access
      end

      def contact
        @contact ||= @event_payload['contact']
      end

      def <=>(other)
        other.is_a?(CreateOrUpdatePerson) || other.is_a?(CreateDeal) ? -1 : 0
      end
    end
  end
end
