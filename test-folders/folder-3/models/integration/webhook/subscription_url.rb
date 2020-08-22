class Integration
  class Webhook
    module SubscriptionUrl
      STAGING_URL = 'https://integrations-staging.rdstation.com/pipedrive/api/v1/event_listener'.freeze
      PRODUCTION_URL = 'https://integrations.rdstation.com/pipedrive/api/v1/event_listener'.freeze

      URLS = {
        'production' => PRODUCTION_URL,
        'staging' => STAGING_URL,
        'development' => STAGING_URL,
      }.freeze

      def self.build(integration, environment)
        "#{URLS[environment]}/#{integration.uuid}"
      end
    end
  end
end
