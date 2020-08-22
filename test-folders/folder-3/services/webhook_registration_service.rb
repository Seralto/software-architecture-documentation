# TODO: create unregister method and use this service on disconnection
module WebhookRegistrationService
  include PipedriveAppLogger
  extend self

  def register(account_id:, integration:, event_type:)
    subscription_url = Integration::Webhook::SubscriptionUrl.build(integration, Rails.env)
    webhooks_client = webhooks_client_by_integration(integration)
    payload = payload_by_integration(integration, event_type, subscription_url)
    event_type = OpenStruct.new(id: nil) if integration.pipedrive_to_rdstation?

    log_info(
      account_id: account_id,
      integration: integration.uuid,
      event_type: event_type.attributes,
      subscription_url: subscription_url,
      webhooks_client: webhooks_client,
      payload: payload,
      message: 'WebhookRegistrationService-register',
    )

    Integration::Webhook.new(integration, webhooks_client).create(event_type, payload)
  end

  def current_webhook(integration_id:, event_type_id:)
    Webhook.find_by(
      integration_id: integration_id,
      event_type_id: event_type_id,
    )
  end

  def unregister_all(account_id:)
    Account.find(account_id).integrations.each do |integration|
      Integration::Webhook.new(integration, webhooks_client_by_integration(integration)).delete_all
    end
  end

  private

  def webhooks_client_by_integration(integration)
    if integration.rdstation_to_pipedrive?
      RdstationClient::Webhooks.new(rdstation_authorization(integration.account.id))
    else
      Pipedrive::Webhooks.new(pipedrive_authorization(integration.account.id))
    end
  end

  def payload_by_integration(integration, event_type, subscription_url)
    if integration.rdstation_to_pipedrive?
      Integration::Webhook::Payload::Rdstation.new(event_type, subscription_url)
    else
      Integration::Webhook::Payload::Pipedrive.new(subscription_url)
    end
  end

  def rdstation_authorization(account_id)
    AuthorizationRdstation.find_by(account_id: account_id)
  end

  def pipedrive_authorization(account_id)
    AuthorizationPipedrive.find_by(account_id: account_id)
  end
end
