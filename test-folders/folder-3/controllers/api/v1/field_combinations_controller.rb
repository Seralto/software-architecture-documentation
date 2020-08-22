module Api
  module V1
    class FieldCombinationsController < AccountTokenProtectedController
      NOT_FOUND_ERROR = {
        'error_type' => 'NOT_FOUND',
        'error_message' => 'Resource not found.',
      }.freeze

      INVALID_ENTITY_ERROR = {
        'error_type' => 'INVALID_ENTITY',
        'error_message' => "Only 'person', 'organization' and 'deal' are valid entities.",
      }.freeze

      before_action :ensure_field_combination, :validate_mapping_entities, only: :update

      def all
        render json: field_mapping.api_representation, status: :ok
      end

      def update
        field_combination.update(mapping: field_mapping.database_format(mapping))
        render json: field_mapping.api_representation, status: :ok
      end

      private

      def ensure_field_combination
        return if field_combination.present?

        render json: NOT_FOUND_ERROR, status: :not_found
      end

      def validate_mapping_entities
        valid_entities = %w[person organization deal].sort
        return if mapping.keys.sort == valid_entities

        render json: INVALID_ENTITY_ERROR, status: :bad_request
      end

      def mapping
        params[:mapping]
      end

      def field_combination
        @field_combination ||= account.field_combination
      end

      def field_mapping
        @field_mapping ||= FieldService::Mapping.new(account)
      end
    end
  end
end
