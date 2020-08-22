module FieldService
  class PipedriveField
    REJECTED_FIELDS = %w[
      owner_id
      org_id
      id
      visible_to
      add_time
      update_time
      open_deals_count
      next_activity_date
      last_activity_date
      won_deals_count
      lost_deals_count
      closed_deals_count
      activities_count
      undone_activities_count
      done_activities_count
      user_id
      person_id
      stage_id
      creator_user_id
    ].freeze

    def initialize(account_id)
      @account_id = account_id
    end

    def all
      [
        pipedrive_person_fields,
        pipedrive_organization_fields,
        pipedrive_deal_fields,
      ].flatten
    end

    def group_by_entities
      {
        'person' => pipedrive_person_fields,
        'organization' => pipedrive_organization_fields,
        'deal' => pipedrive_deal_fields,
      }
    end

    private

    attr_reader :account_id

    def pipedrive_person_fields
      @pipedrive_person_fields = begin
        person_fields = pipedrive_fields_client.by_type('personFields')
        replace_key_with_id(reject_fields(person_fields))
      end
    end

    def pipedrive_organization_fields
      @pipedrive_organization_fields = begin
        organization_fields = pipedrive_fields_client.by_type('organizationFields')
        replace_key_with_id(reject_fields(organization_fields))
      end
    end

    def pipedrive_deal_fields
      @pipedrive_deal_fields = begin
        deal_fields = pipedrive_fields_client.by_type('dealFields')
        replace_key_with_id(reject_fields(deal_fields))
      end
    end

    def pipedrive_fields_client
      @pipedrive_fields_client ||= Pipedrive::Fields.new(pipedrive_authorization)
    end

    def pipedrive_authorization
      @pipedrive_authorization ||= AuthorizationPipedrive.find_by(account_id: account_id)
    end

    def reject_fields(fields)
      fields.reject { |field| REJECTED_FIELDS.include?(field['key']) }
    end

    def replace_key_with_id(fields)
      fields.map { |field| { 'id' => field['key'], 'name' => field['name'] } }
    end
  end
end
