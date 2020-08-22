module FieldService
  class Mapping
    class DatabaseFormatter
      # Public: Transform a field mapping into a format that the database understands
      #
      # entity_mapping - A hash containing the field mapping of a specific entity
      #
      # Examples
      #
      # format(
      #   [
      #     {
      #       "rdstation" => {
      #         "id" => "company_name",
      #         "name"=>"Company Name"
      #        },
      #        "pipedrive" => {
      #          "id" => "name",
      #          "name" => "Name"
      #        }
      #      }
      #    ]
      #  )
      #   # => { "name" => company_name }
      #
      # Returns the duplicated String.
      def self.format(entity_mapping)
        entity_mapping.each_with_object({}) do |mapping, mapping_hash|
          pipedrive_field_id = mapping['pipedrive']['id']
          rdstation_field_id = mapping['rdstation']['id']
          mapping_hash[pipedrive_field_id] = rdstation_field_id
        end
      end
    end
  end
end
