module FieldService
  class Mapping
    def initialize(account)
      @account = account
    end

    def api_representation
      {
        'deal' => transformation.to_api_representation(field_mapping['deal']),
        'person' => transformation.to_api_representation(field_mapping['person']),
        'organization' => transformation.to_api_representation(field_mapping['organization']),
      }
    end

    def database_format(mapping)
      {
        'deal' => database_formatter.format(mapping['deal']),
        'person' => database_formatter.format(mapping['person']),
        'organization' => database_formatter.format(mapping['organization']),
      }
    end

    private

    def transformation
      @transformation ||= FieldService::Mapping::Transformation.new(
        pipedrive_fields: pipedrive_fields.all,
        rdstation_fields: rdstation_fields.all,
      )
    end

    def database_formatter
      FieldService::Mapping::DatabaseFormatter
    end

    def field_combination
      @field_combination ||= @account.field_combination
    end

    def field_mapping
      field_combination.mapping
    end

    def pipedrive_fields
      @pipedrive_fields ||= FieldService::PipedriveField.new(@account.id)
    end

    def rdstation_fields
      @rdstation_fields ||= FieldService::RdstationField.new(@account.id)
    end
  end
end
