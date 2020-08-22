module FieldService
  class AccountField
    def initialize(account_id)
      @account_id = account_id
    end

    def all
      {
        rdstation: rdstation_fields.group_by_entities,
        pipedrive: pipedrive_fields.group_by_entities,
      }
    end

    private

    attr_reader :account_id

    def pipedrive_fields
      @pipedrive_fields ||= FieldService::PipedriveField.new(account_id)
    end

    def rdstation_fields
      @rdstation_fields ||= FieldService::RdstationField.new(account_id)
    end
  end
end
