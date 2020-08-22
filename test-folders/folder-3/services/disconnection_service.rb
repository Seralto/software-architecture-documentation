class DisconnectionService
  include PipedriveAppLogger
  attr_reader :account_id, :disconnection_type

  def initialize(account_id:, disconnection_type:)
    @account_id = account_id
    @disconnection_type = DisconnectionService::Type.new(disconnection_type)
  end

  def disconnect
    delete_webhooks
    revoke_credentials
    delete_authorization
    delete_rules
    reset_field_combination
  rescue StandardError => error
    extra = { account_id: account_id, disconnection_type: disconnection_type.raw }
    Rollbar.error(error, 'MoTeam-PipedriveApp-DisconnectionService', extra)
    log_disconnection_error(msg: 'disconnection_error', error: error)
    raise error
  end

  private

  def delete_webhooks
    Integration::Webhook.new(integration, webhook_client).delete_all
    log_disconnection_info(msg: 'delete_webhooks_success', integration: integration, webhook_client: webhook_client)
  rescue Pipedrive::Error::InvalidRefreshToken, RDStation::Error::InvalidCredentials
    log_disconnection_error(msg: 'delete_webhooks_err-inv_cr', integration: integration, webhook_client: webhook_client)
    # Integration already removed
  end

  def webhook_client
    webhook_client_class.new(authorization)
  end

  def webhook_client_class
    return RdstationClient::Webhooks if disconnection_type.rdstation?
    return Pipedrive::Webhooks if disconnection_type.pipedrive?
  end

  def integration
    Integration.find_by(account_id: account_id, type: integration_type)
  end

  def integration_type
    return Integration.types['rdstation_to_pipedrive'] if disconnection_type.rdstation?
    return Integration.types['pipedrive_to_rdstation'] if disconnection_type.pipedrive?
  end

  def authorization
    Authorization.find_by(type: disconnection_type.raw, account_id: account_id)
  end

  def revoke_credentials
    revoke_rdstation_auth if disconnection_type.rdstation?
    revoke_pipedrive_auth if disconnection_type.pipedrive?
  end

  def revoke_rdstation_auth
    RdstationClient::Authorization.retryable_revoke(context: context, authorization: authorization)
    log_disconnection_info(msg: 'revoke_rdstation_auth_success', authorization: authorization)
  end

  def revoke_pipedrive_auth
    client = Pipedrive::Authorization.new(ENV['PIPEDRIVE_CLIENT_ID'], ENV['PIPEDRIVE_CLIENT_SECRET'])
    client.revoke(refresh_token: authorization.refresh_token)
    log_disconnection_info(msg: 'revoke_pipedrive_auth_success', authorization: authorization)
  end

  def delete_authorization
    authorization.destroy!
    log_disconnection_info(msg: 'delete_authorization_success', authorization: authorization)
  end

  def delete_rules
    integration.rules.destroy_all
    log_disconnection_info(msg: 'delete_rules_success')
  end

  def reset_field_combination
    Account.find(account_id).reset_field_combination
    log_disconnection_info(msg: 'reset_field_combination_success')
  end

  def log_disconnection_info(hash)
    log_info(hash.merge(disconnection_type: disconnection_type.raw, account_id: account_id))
  end

  def log_disconnection_error(hash)
    log_error(hash.merge(disconnection_type: disconnection_type.raw, account_id: account_id))
  end

  def context
    @context ||= Mstk::Context.create(@account_id)
  end
end
