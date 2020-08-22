module FieldService
  class Mapping
    module Attributes
      class Error
        DELETED_FIELD_ERROR = 'DELETED_FIELD'.freeze

        def initialize(field)
          @field = field
        end

        def to_hash
          {
            'error' => error_code,
            'active' => active_field?,
          }
        end

        private

        def active_field?
          @field.present?
        end

        def error_code
          return if active_field?

          DELETED_FIELD_ERROR
        end
      end
    end
  end
end
