module Api
  module V1
    class MigrationsController < ApplicationController
      include PipedriveAppLogger
      skip_before_action :verify_authenticity_token, only: :migrate

      def check_integration
        current_user_platform_account_id = platform_account_id
        return render json: { needs_migration: false } unless current_user_platform_account_id

        has_integration = Migration::IntegrationService.new(current_user_platform_account_id).user_has_integration?
        needs_migration = has_integration && did_not_migrate
        log_info(msg: 'Migration - check integration', platform_account_id: platform_account_id, needs_migration: needs_migration)
        render json: { needs_migration: needs_migration }
      end

      def migrate
        Migration::MigratorService.new(platform_account_id).perform
        log_info(msg: 'Migration - succesfully migrated', platform_account_id: platform_account_id)
        render json: { message: t('migrations.success_message'), type: 'success' }, status: :ok
      rescue StandardError => error
        extra = { platform_account_id: platform_account_id }
        Rollbar.error(error, 'MoTeam-PipedriveApp-MigrationService', extra)
        render json: { message: t('migrations.error_message'), type: 'danger' }, status: :unprocessable_entity
      end

      private

      def platform_account_id
        current_account&.platform_account_id
      end

      def did_not_migrate
        !current_account.migrated
      end
    end
  end
end
