module Api
  module V1
    class ActionsSerializer < ActiveModel::Serializer
      attributes :id, :name, :event, :stages, :creation_order

      def event
        object.event.slice(:id, :allow_stage, :category, :description, :integration_type)
      end

      def stages
        object.actions_rules.find_by(
          action_id: object.id,
          rule_id: @instance_options[:rule_id],
        ).stages
      end

      def creation_order
        object.actions_rules.find_by(
          action_id: object.id,
          rule_id: @instance_options[:rule_id],
        ).creation_order
      end
    end
  end
end
