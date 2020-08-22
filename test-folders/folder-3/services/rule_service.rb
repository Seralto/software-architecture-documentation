class RuleService
  def initialize(name:, integration_id:, event_id:, actions_params:, filters: {})
    @name = name
    @integration_id = integration_id
    @event_id = event_id
    @actions_params = actions_params
    @filters = filters
  end

  def create
    Rule.transaction do
      rule = Rule.new(
        name: @name,
        integration_id: @integration_id,
        trigger: Trigger.create!(event_id: @event_id, filters: @filters),
      )
      rule.actions = actions_by_event_ids
      rule.save!
      after_save_actions(rule)
    end
  end

  def update(id)
    rule = Rule.find(id)

    Rule.transaction do
      rule.update(
        name: @name,
        integration_id: @integration_id,
        actions: actions_by_event_ids,
      )
      rule.trigger.update(
        event_id: @event_id,
        filters: @filters,
      )

      rule.save!
      after_save_actions(rule)
    end
  end

  private

  def actions_by_event_ids
    event_ids = @actions_params.map { |action| action['event_id'] }
    Action.where(event_id: event_ids)
  end

  def after_save_actions(rule)
    rule.actions_rules.each do |action_rule|
      new_action_values = @actions_params.find { |action| action['event_id'].to_i == action_rule.action.event_id }
      next if new_action_values.blank?

      action_rule.stages = new_action_values['stages']
      action_rule.creation_order = new_action_values['creation_order']

      action_rule.save
    end
    rule
  end
end
