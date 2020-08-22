class Integration
  class Webhook
    module Payload
      class Rdstation
        attr_reader :event_type, :subscription_url

        def initialize(event_type, subscription_url)
          @event_type = event_type
          @subscription_url = subscription_url
        end

        def to_hash
          {
            'entity_type' => 'CONTACT',
            'event_type' => event_type.rd_identifier,
            'url' => subscription_url,
            'http_method' => 'POST',
            'include_relations' => %w[COMPANY CONTACT_FUNNEL],
          }
        end
      end
    end
  end
end
