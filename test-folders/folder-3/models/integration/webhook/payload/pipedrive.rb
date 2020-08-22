class Integration
  class Webhook
    module Payload
      class Pipedrive
        attr_reader :subscription_url

        def initialize(subscription_url)
          @subscription_url = subscription_url
        end

        def to_hash
          {
            'subscription_url' => subscription_url,
            'event_action' => 'updated',
            'event_object' => 'deal',
          }
        end
      end
    end
  end
end
