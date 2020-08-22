module RdstationClient
  module ClientWithCache
    class Webhooks
      def initialize(webhooks)
        @webhooks = webhooks
      end

      def by_uuid(uuid)
        Rails.cache.fetch(cache_key(uuid), expires_in: 24.hours) do
          @webhooks.by_uuid(uuid)
        end
      end

      def create(webhooks_payload)
        @webhooks.create(webhooks_payload)
      end

      private

      def cache_key(uuid)
        "#{account_id}/rdstation_webhooks/#{uuid}"
      end

      def account_id
        @account_id ||= @webhooks.authorization.account_id
      end
    end
  end
end
