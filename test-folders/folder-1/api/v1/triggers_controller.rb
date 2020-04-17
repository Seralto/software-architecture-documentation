module Api
  module V1
    class TriggersController < AccountTokenProtectedController
      PERMITTED_RELATIONS = %w[
        event
      ].freeze

      before_action :validate_included_relations, only: :all

      def all
        render json: triggers.to_json(
          include: included_relations,
          except: %w[created_at updated_at],
        ), status: :ok
      end

      def by_rule
        trigger_json = rule.trigger.to_json(include: :event)
        render json: trigger_json,
               status: :ok
      rescue ActiveRecord::RecordNotFound
        render_not_found
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

      def rule
        @rule ||= Rule.find(params[:rule_id])
      end

      def render_not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end

      def triggers
        @triggers ||= Trigger.all
      end
    end
  end
end
