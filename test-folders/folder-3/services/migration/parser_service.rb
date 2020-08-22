module Migration
  class ParserService
    class << self
      DEFAULT_STAGE_ID = '1'.freeze
      ENTITIES = %w[person organization deal].freeze
      FIELD_NAME_MAPPINGS = {
        'uf' => 'state',
        'city_name' => 'city',
        'source' => 'funnel.origin',
        'lifecycle_stage' => 'funnel.lifecycle_stage',
        'user.email' => 'funnel.contact_owner_email',
        'score.interest' => 'funnel.interest',
        'score.fit_score_label' => 'funnel.fit',
        'last_conversion_identifier' => 'event_identifier',
      }.freeze

      def parse_fields_combination(field_combination)
        ENTITIES.each do |entity|
          field_combination[entity].map do |pipe_field, rd_field|
            field_combination[entity][pipe_field] = parse_field(rd_field)
          end
        end
        merge_default_mapping(field_combination)
      end

      def parse_stages(stages)
        stages.map do |stage|
          stage.map do |email_or_default, stage_id|
            {
              'field_type' => field_type(email_or_default),
              'field_value' => email_or_default,
              'stage_id' => stage_id || DEFAULT_STAGE_ID,
            }
          end
        end.flatten
      end

      private

      def parse_field(field)
        return FIELD_NAME_MAPPINGS[field] if FIELD_NAME_MAPPINGS[field]

        field.gsub('lead_info.', '').gsub('pg_', '')
      end

      def merge_default_mapping(field_combination)
        field_combination.tap do |combination|
          combination['person']['phone'] = 'personal_phone'
        end
      end

      def field_type(email_or_default)
        email_or_default == 'default' ? 'default' : 'contact_owner_email'
      end
    end
  end
end
