module Platform
  class AuthorizationService
    ALLOWED_STATUSES = %w[trial active past_due].freeze

    def self.get_authorized_platform_accounts_for(user_email)
      user_request = get_user_request_for(user_email)
      user = user_request.response.user
      accounts = select_active_or_past_due_rdsm_accounts(user.platform_accounts.values)
      accounts.map { |account| { name: account.platform_account_name, id: account.platform_account_id } }
    end

    def self.select_active_or_past_due_rdsm_accounts(platform_accounts)
      platform_accounts.select do |account|
        account.subscriptions['rdsm'].present? && ALLOWED_STATUSES.include?(account.subscriptions['rdsm'].status)
      end
    end

    def self.get_user_request_for(user_email)
      context = Mstk::Context.create
      request = Platform::A3S::Model::GetUserRequest.new
      request.key = A3Model::UserKey.new(user_email: user_email)
      Platform::A3S::API::UserClient.get_user(context, request)
    end

    def self.get_platform_account_request_for(platform_account_id)
      context = Mstk::Context.create
      request = Platform::A3S::Model::GetPlatformAccountRequest
      request = request.new(platform_account_id: platform_account_id)
      Platform::A3S::API::PlatformAccountClient.get_platform_account(context, request)
    end

    private_class_method :get_user_request_for, :select_active_or_past_due_rdsm_accounts, :get_platform_account_request_for
  end
end
