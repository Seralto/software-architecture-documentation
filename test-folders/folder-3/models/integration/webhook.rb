class Integration
  class Webhook
    include PipedriveAppLogger
    attr_reader :webhooks_client, :integration

    def initialize(integration, webhooks_client)
      @integration = integration
      @webhooks_client = webhooks_client
    end

    def create(event_type, payload)
      webhook = webhooks_client.create(payload.to_hash)

      ::Webhook.create(
        integration_id: integration.id,
        event_type_id: event_type.id,
        platform_identifier: webhook['uuid'] || webhook.dig('data', 'id'),
      )
    end

    def delete_all
      ::Webhook.where(integration_id: integration.id).each do |webhook|
        begin
          webhooks_client.delete(webhook.platform_identifier)
          webhook.destroy!
        rescue RDStation::Error::NotFound
          log_error(
            integration_id: integration.id,
            error_message: "Webhook with UUID #{webhook.platform_identifier} was already deleted at RDSM",
          )
        end
      end
    end
  end
end
