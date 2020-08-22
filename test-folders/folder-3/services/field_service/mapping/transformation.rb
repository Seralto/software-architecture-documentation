module FieldService
  class Mapping
    class Transformation
      def initialize(pipedrive_fields:, rdstation_fields:)
        @pipedrive_fields = pipedrive_fields
        @rdstation_fields = rdstation_fields
      end

      def to_api_representation(mapping)
        mapping.map do |pipedrive_identifier, rd_identifier|
          {
            'rdstation' => find_field(rdstation_fields, rd_identifier),
            'pipedrive' => find_field(pipedrive_fields, pipedrive_identifier),
          }
        end
      end

      private

      attr_reader :rdstation_fields, :pipedrive_fields

      def find_field(all_fields, id)
        attributes = all_fields.find { |field| field['id'] == id }.to_h
        errors = attribute_error(attributes)
        attributes.merge(errors)
      end

      def attribute_error(field)
        Attributes::Error.new(field).to_hash
      end
    end
  end
end
