module Api
  module V1
    class UsersController < AccountTokenProtectedController
      def rdstation_users
        users = rdstation_users_client.by_account(context, account.platform_account_id)
        return render json: users, status: :ok if users

        render json: rd_internal_api_error, status: :internal_server_error
      end

      private

      def rd_internal_api_error
        {
          'error_type' => 'INTERNAL_API_ERROR',
          'error_message' => 'Error when recovering RD Station Users',
        }
      end

      def context
        @context ||= Mstk::Context.create(account.id)
      end

      def rdstation_users_client
        @rdstation_users_client ||= RdstationInternal::ClientWithCache::Users.new(
          RdstationInternal::Users.new,
        )
      end
    end
  end
end
