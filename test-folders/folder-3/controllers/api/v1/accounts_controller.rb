module Api
  module V1
    class AccountsController < AccountTokenProtectedController
      USER_UNAUTHORIZED_ERROR = {
        'error' => 'UNAUTHORIZED',
        'message' => 'The user is not authorized to access this page.',
      }.freeze

      EXPIRED_SESSION_ERROR = {
        'error' => 'EXPIRED_SESSION',
        'message' => 'The user session has expired.',
      }.freeze

      include Session

      before_action :ensure_user, :validate_session_token, only: :authorizations

      def authorizations
        auth_info = {
          'authentication_info' => {
            'user' => user_info['email'],
          },
          'authorization_info' => {
            'pipedrive' => pipedrive_authorization_info.to_hash,
            'rdstation' => rdstation_authorization_info.to_hash,
          },
        }
        render json: auth_info, status: :ok
      end

      private

      def pipedrive_authorization_info
        AuthorizationInfo.new(pipedrive_authorization)
      end

      def rdstation_authorization_info
        AuthorizationInfo.new(rdstation_authorization)
      end

      def user_info
        session['user_info']
      end

      def ensure_user
        return if user_info.present?

        render json: USER_UNAUTHORIZED_ERROR, status: :unauthorized
      end

      def validate_session_token
        return if user_signed_in?

        render json: EXPIRED_SESSION_ERROR, status: :unauthorized
      end

      def rdstation_authorization
        @rdstation_authorization ||= AuthorizationRdstation.find_by(account_id: account.id)
      end

      def pipedrive_authorization
        @pipedrive_authorization ||= AuthorizationPipedrive.find_by(account_id: account.id)
      end
    end
  end
end
