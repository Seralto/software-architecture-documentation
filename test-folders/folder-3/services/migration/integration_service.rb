module Migration
  class IntegrationService
    def initialize(platform_account_id)
      @platform_account_id = platform_account_id
    end

    def user_has_integration?
      return false unless account_has_authorizations? && completed_legacy_integration?

      token = legacy_tokens&.first
      return false unless token && token['private']

      url = subscription_url(token['private'])
      resp = webhook_client.by_subscription_url(url)
      admin_id = resp['admin_id'] if resp
      admin_id == pipedrive_user_id
    end

    private

    def account_has_authorizations?
      rdstation_authorization && pipedrive_authorization
    end

    def completed_legacy_integration?
      # NOTE: The 'custom_fields' field only has data when the integration process was completed.
      #       The value '{}' means the integration was not completed.
      integration_data['custom_fields'].any?
    end

    def legacy_tokens
      path = 'https://api.rd.services/platform/legacy/tokens'
      response = HTTParty.get(path, headers: auth_header)
      response = JSON.parse(response.body)
      response['tokens']
    end

    def subscription_url(token)
      "https://www.rdstation.com.br/api/1.2/services/#{token}/pipedrive"
    end

    def webhook_client
      @webhook_client ||= Pipedrive::Webhooks.new(pipedrive_authorization)
    end

    def auth_header
      { 'Authorization' => "Bearer #{rdstation_authorization.access_token}" }
    end

    def account
      @account ||= Account.find_by(platform_account_id: @platform_account_id)
    end

    def pipedrive_user_id
      user = pipedrive_client.get('users/me')
      @pipedrive_user_id ||= user['data']['id'] if user['success']
    end

    def pipedrive_client
      Pipedrive::Request.new(pipedrive_authorization)
    end

    def rdstation_authorization
      @rdstation_authorization ||= AuthorizationRdstation.find_by(account_id: account.id)
    end

    def pipedrive_authorization
      @pipedrive_authorization ||= AuthorizationPipedrive.find_by(account_id: account.id)
    end

    def context
      Mstk::Context.create(account.id, platform_account_id: @platform_account_id)
    end

    def integration_data
      client.by_account(context, @platform_account_id)
    end

    def client
      RdstationInternal::PipedriveNotifications.new
    end
  end
end
