module Api
  module V1
    class RulesController < AccountTokenProtectedController
      include PipedriveAppLogger

      before_action :ensure_rule, only: %i[update delete by_id]
      before_action :ensure_rule_ownership, only: %i[update delete by_id]

      def all
        render json: account_rules, status: :ok
      end

      def by_id
        render json: rule.to_json(except: %w[created_at updated_at]), status: :ok
      end

      def create
        log('Create webhook')
        create_webhook unless current_webhook.present?

        created_rule = create_rule
        return head :bad_request unless created_rule

        json_rule = created_rule.to_json(except: %w[created_at updated_at])
        render json: json_rule, status: :created
      end

      def update
        log('Update webhook')
        create_webhook unless current_webhook.present?

        updated_rule = update_rule
        return head :bad_request unless updated_rule

        json_rule = updated_rule.to_json(except: %w[created_at updated_at])
        render json: json_rule, status: :ok
      end

      def delete
        rule.destroy
        WebhookRegistrationService.unregister_all(account_id: account.id) if account_rules.empty?
        head :no_content
      end

      def integration_by_rule
        render json: integration.to_json(except: %i[created_at updated_at]), status: :ok
      end

      private

      def create_webhook
        WebhookRegistrationService.register(
          account_id: account.id,
          integration: account_integration_by_type,
          event_type: event_type,
        )
      end

      def create_rule
        RuleService.new(
          event_id: permitted_params[:triggerEventId],
          filters: permitted_params[:filters],
          actions_params: permitted_params[:actions],
          name: permitted_params[:title],
          integration_id: account_integration_by_type.id,
        ).create
      end

      def update_rule
        RuleService.new(
          filters: permitted_params[:filters],
          event_id: permitted_params[:triggerEventId],
          actions_params: permitted_params[:actions],
          name: permitted_params[:title],
          integration_id: account_integration_by_type.id,
        ).update(rule.id)
      end

      def account_integration_by_type
        @account_integration_by_type ||= account.integrations.find_by(type: permitted_params[:integration])
      end

      def permitted_params
        params.require(:rule).permit!
      end

      def render_not_found
        render json: { error: 'NOT_FOUND', message: 'Resource not found' }, status: :not_found
      end

      def render_forbidden
        render json: { error: 'FORBIDDEN', message: 'Forbidden resource' }, status: :forbidden
      end

      def rule
        @rule ||= Rule.find_by(id: params[:rule_id])
      end

      def actions
        @actions ||= rule.actions
      end

      def integration
        @integration ||= rule.integration
      end

      def ensure_rule
        render_not_found unless rule
      end

      def ensure_rule_ownership
        render_forbidden unless account_rules.include?(rule)
      end

      def account_rules
        @account_rules ||= account.rules
      end

      def current_webhook
        @current_webhook ||= WebhookRegistrationService.current_webhook(
          integration_id: account_integration_by_type.id,
          event_type_id: event_type.try(:id),
        )
      end

      def event_type
        return nil if account_integration_by_type.type == 'pipedrive_to_rdstation'

        Event.find(permitted_params[:triggerEventId]).event_type
      end

      def log(message)
        log_info(
          account_id: account.id,
          integration_id: account_integration_by_type.id,
          integration_type: account_integration_by_type.type,
          event_type: event_type,          
          current_webhook_present: current_webhook.present?,
          message: message,
        )
      end
    end    
  end
end
