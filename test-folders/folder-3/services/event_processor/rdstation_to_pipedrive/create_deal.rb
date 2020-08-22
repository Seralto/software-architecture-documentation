module EventProcessor
  class RdstationToPipedrive
    class CreateDeal
      include Comparable
      include ::PipedriveAppLogger
      include EventProcessor::RequestLogger

      EVENT_TYPE = 'CREATE_DEAL'.freeze

      def initialize(account_id, field_combination, event_payload, stages)
        @account_id = account_id
        @field_combination = field_combination
        @event_payload = event_payload
        @stages = stages.map(&:with_indifferent_access)
      end

      def process(state_chain = {})
        deal_payload = process_payload(state_chain)
        log_event_processing(deal_payload)
        create(deal_payload)
      end

      private

      def process_payload(state_chain)
        related_entities_params = related_entities_params(state_chain)
        deal_payload = payload.merge(related_entities_params)
        deal_payload = stage_field.merge(deal_payload)
        deal_payload['title'] = company_or_contact_name if deal_payload['title'].blank?
        deal_payload['user_id'] = PipedriveOwnerHelper.new(@event_payload, authorization).find_owner_id
        deal_payload.compact
      end

      def create(deal_payload)
        response = deals_client.create(deal_payload)
        response.deep_symbolize_keys!
        if response[:success]
          log_response_success(response)
          { deal_id: response[:data][:id] }
        else
          log_response_error(response)
          {}
        end
      end

      def related_entities_params(state_chain)
        {
          'org_id' => state_chain[:organization_id],
          'person_id' => state_chain[:person_id],
        }.compact
      end

      def stage_field
        stage_id = default_stage.try(:[], :stage_id)
        if funnel.present?
          stage = custom_stages.find { |custom_stage| funnel[custom_stage[:field_type]] == custom_stage[:field_value] }
          stage_id = stage[:stage_id] if stage.present?
        end

        { 'stage_id' => stage_id }
      end

      def funnel
        contact['funnel']
      end

      def custom_stages
        @stages.reject { |stage| stage[:field_type] == 'default' }
      end

      def default_stage
        @stages.select { |stage| stage[:field_type] == 'default' }.first
      end

      def company_or_contact_name
        campany_name = contact.dig('company', 'name')
        return campany_name unless campany_name.blank?

        contact['name']
      end

      def deals_client
        Pipedrive::Deals.new(authorization)
      end

      def authorization
        @authorization ||= AuthorizationPipedrive.find_by(account_id: @account_id)
      end

      def payload
        @payload ||= @field_combination.map_values_for_pipedrive(
          entity_type: 'deal',
          entity_payload: contact,
        )
      end

      def contact
        @contact ||= @event_payload['contact']
      end

      def <=>(other)
        other.is_a?(CreateOrUpdatePerson) || other.is_a?(CreateOrUpdateOrganization) ? +1 : 0
      end
    end
  end
end
