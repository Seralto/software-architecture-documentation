module RdstationInternal
  module ClientWithCache
    class Users
      def initialize(users_client)
        @users_client = users_client
      end

      def by_account(context, platform_account_id)
        Rails.cache.fetch(cache_key(platform_account_id), expires_in: 24.hours) do
          @users_client.by_account(context, platform_account_id)
        end
      end

      private

      def cache_key(rdstation_platform_account_id)
        "rdstation_users/#{rdstation_platform_account_id}"
      end
    end
  end
end
