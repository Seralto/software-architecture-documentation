class FieldCombination < ApplicationRecord
  belongs_to :account

  # pattern { 'pipedrive' => 'rdstation' }
  DEFAULT_MAPPING = {
    'deal' => { 'title' => 'company.name' },
    'person' => { 'name' => 'name', 'email' => 'email' },
    'organization' => { 'name' => 'company.name' },
  }.freeze

  def map_values_for_rdstation(entity_type:, entity_payload:)
    entity_mapping = mapping[entity_type] || {}

    entity_mapping.each_with_object({}) do |field_mapping, processed_fields|
      pipedrive_field, rd_field = field_mapping
      processed_fields[rd_field] = entity_payload[pipedrive_field]
    end.compact
  end

  def map_values_for_pipedrive(entity_type:, entity_payload:)
    entity_mapping = mapping[entity_type] || {}

    entity_mapping.each_with_object({}) do |field_mapping, processed_fields|
      pipedrive_field, rd_field = field_mapping
      processed_fields[pipedrive_field] = entity_payload.dig(*rd_field.split('.'))
    end.compact
  end
end
