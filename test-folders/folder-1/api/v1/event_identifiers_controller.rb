module Api
  module V1
    class EventIdentifiersController < AccountTokenProtectedController
      def all
        render json: identifiers, status: :ok
      end

      private

      def identifiers
        RdstationClient::EventIdentifiers.new(authorization).all
      end

      def authorization
        current_account.authorizations.rdstation.take
      end
    end
  end
end
