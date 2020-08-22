module EventProcessor
  class PipedriveToRdstation
    class OpportunityLost < PipedriveEvents
      EVENT_TYPE = 'OPPORTUNITY_LOST'.freeze

      private

      def fixed_fields
        {
          'funnel_name' => 'default',
          'email' => person_email,
          'reason' => current_entity['lost_reason'],
        }
      end
    end
  end
end
