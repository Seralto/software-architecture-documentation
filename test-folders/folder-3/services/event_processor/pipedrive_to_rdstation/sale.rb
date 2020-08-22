module EventProcessor
  class PipedriveToRdstation
    class Sale < PipedriveEvents
      EVENT_TYPE = 'SALE'.freeze

      private

      def fixed_fields
        {
          'funnel_name' => 'default',
          'email' => person_email,
          'value' => current_entity['value'],
        }
      end
    end
  end
end
