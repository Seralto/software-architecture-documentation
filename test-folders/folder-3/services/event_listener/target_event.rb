module EventListener
  class TargetEvent
    attr_reader :integration, :platform_event_id

    def initialize(integration, platform_event_id, payload)
      @integration = integration
      @platform_event_id = platform_event_id
      @payload = payload
    end

    def actions
      triggers.map(&:actions).flatten.uniq
    end

    def actions_rules_with_stage
      return if integration.rules.empty? || triggers.empty?

      actions_rules = integration.rules.find_by(trigger_id: triggers.first.id).actions_rules
      actions_rules.where.not("stages = '[]'")
    end

    private

    def triggers
      triggers = integration.triggers.where(event_id: platform_event_id)
      filter(triggers)
    end

    def filter(triggers)
      [].tap do |filtered|
        triggers.each do |trigger|
          filtered << trigger unless trigger.event.event_type.rd_conversion?
          filtered << trigger if trigger.filters.nil? || matches_filters?(trigger)
        end
      end
    end

    def matches_filters?(trigger)
      return unless trigger.filters['conversion_identifier']

      @payload['event_identifier'].nil? ||
        trigger.filters['conversion_identifier'].empty? ||
        trigger.filters['conversion_identifier'].include?(@payload['event_identifier'])
    end
  end
end
