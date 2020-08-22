module FieldService
  class RdstationField
    EXTRA_FIELDS = [
      {
        'id' => 'company.name',
        'name' => 'Nome da Empresa',
      },
      {
        'id' => 'funnel.origin',
        'name' => 'Origem do Lead',
      },
      {
        'id' => 'city',
        'name' => 'Cidade',
      },
      {
        'id' => 'funnel.lifecycle_stage',
        'name' => 'Estágio do funil',
      },
      {
        'id' => 'funnel.contact_owner_email',
        'name' => 'Dono do Lead',
      },
      {
        'id' => 'funnel.interest',
        'name' => 'Interesse',
      },
      {
        'id' => 'funnel.fit',
        'name' => 'Fit',
      },
      {
        'id' => 'event_identifier',
        'name' => 'Última Conversão (identificador)',
      },
    ].freeze

    def initialize(account_id)
      @account_id = account_id
    end

    def all
      rdstation_fields
    end

    def group_by_entities
      {
        'person' => rdstation_fields,
        'organization' => rdstation_fields,
        'deal' => rdstation_fields,
      }
    end

    private

    attr_reader :account_id

    def rdstation_fields
      all_rdstation_fields.map do |field|
        {
          'id' => field['api_identifier'],
          'name' => field['label']['default'],
        }
      end.concat(EXTRA_FIELDS)
    end

    def all_rdstation_fields
      rdstation_fields_client.all['fields']
    end

    def rdstation_fields_client
      ::RdstationClient::Fields.new(rdstation_authorization)
    end

    def rdstation_authorization
      AuthorizationRdstation.find_by(account_id: account_id)
    end
  end
end
