module Api
  module V1
    class StagesController < AccountTokenProtectedController
      def pipedrive
        render json: pipedrive_stages.all, status: :ok
      end

      private

      def pipedrive_stages
        Pipedrive::Stages.new(pipedrive_authorization)
      end

      def pipedrive_authorization
        AuthorizationPipedrive.find_by(account_id: account.id)
      end
    end
  end
end
