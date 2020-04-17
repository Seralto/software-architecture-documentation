module Api
  module V1
    class FieldsController < AccountTokenProtectedController
      def all
        render json: account_fields.all, status: :ok
      end

      private

      def account_fields
        @account_fields ||= FieldService::AccountField.new(account)
      end
    end
  end
end
