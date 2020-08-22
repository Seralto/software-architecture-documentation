module Api
  module V1
    class AccountTokenProtectedController < ApplicationController
      UNAUTHORIZED_ERROR = {
        'error' => 'UNAUTHORIZED',
        'message' => 'Invalid authorization token.',
      }.freeze

      before_action :validate_session_account

      protected

      def validate_session_account
        return if account.present?

        render json: UNAUTHORIZED_ERROR, status: :unauthorized
      end

      def account
        @account ||= Account.find_by(id: session[:account_id])
      end
    end
  end
end
