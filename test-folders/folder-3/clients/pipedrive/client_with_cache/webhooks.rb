module Pipedrive
  module ClientWithCache
    class Webhooks
      def initialize(webhooks)
        @webhooks = webhooks
      end

      def by_subscription_url(url)
        Rails.cache.fetch(cache_key, expires_in: 24.hours) do
          @webhooks.by_subscription_url(url)
        end
      end

      def create(webhooks_payload)
        @webhooks.create(webhooks_payload)
      end

      private

      def cache_key
        "#{account_id}/pipedrive_webhooks"
      end

      def account_id
        @account_id ||= @webhooks.authorization.account_id
      end
    end
  end
end
