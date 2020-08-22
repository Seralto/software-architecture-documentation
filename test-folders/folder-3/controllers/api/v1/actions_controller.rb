module Api
  module V1
    class ActionsController < AccountTokenProtectedController
      PERMITTED_RELATIONS = %w[
        event
      ].freeze

      before_action :validate_included_relations, only: :all

      def all
        render json: actions.to_json(
          include: included_relations,
          except: %w[created_at updated_at],
        ), status: :ok
      end

      def by_rule
        render json: actions_by_rule,
               rule_id: rule.id,
               each_serializer: Api::V1::ActionsSerializer,
               status: :ok
      end

      private

      def included_relations
        include_relations.map do |relation|
          { relation => { except: %w[created_at updated_at] } }
        end
      end

      def validate_included_relations
        unpermitted_relations = include_relations - PERMITTED_RELATIONS
        return if unpermitted_relations.empty?

        render json: unpermitted_relations_error(unpermitted_relations), status: :bad_request
      end

      def include_relations
        params[:include_relations] || []
      end

      def unpermitted_relations_error(relations)
        {
          error: 'UNPERMITTED_RELATIONS',
          message: "The following relations are not permitted for this resource: '#{relations.join(', ')}'",
        }
      end

      def actions
        @actions ||= Action.all
      end

      def rule
        @rule ||= Rule.find(params[:rule_id])
      end

      def actions_by_rule
        @actions_by_rule ||= rule.actions.includes(:actions_rules).order('actions_rules.creation_order')
      end
    end
  end
end
