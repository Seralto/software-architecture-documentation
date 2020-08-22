module RdstationClient
  class Client
    attr_accessor :authorization

    delegate :request, to: :retryable_api_client

    RETRYABLE_AUTHORIZATION_ERRORS = [
      RDStation::Error::ExpiredAccessToken,
      RDStation::Error::Unauthorized,
    ].freeze

    def initialize(authorization)
      @authorization = authorization
    end

    def authorization_client
      @authorization_client ||= RdstationClient::Authorization.new(
        ENV['RDSTATION_CLIENT_ID'],
        ENV['RDSTATION_CLIENT_SECRET'],
      )
    end

    private

    def account
      @account ||= authorization.account
    end

    def context
      Mstk::Context.create(account.id, platform_account_id: account.platform_account_id)
    end

    def retryable_api_client
      @retryable_api_client ||= RetryableApiClient.new(context, authorization, self)
    end
  end
end
