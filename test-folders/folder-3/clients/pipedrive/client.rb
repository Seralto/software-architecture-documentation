module Pipedrive
  class Client
    attr_accessor :authorization

    delegate :request, to: :retryable_api_client

    RETRYABLE_AUTHORIZATION_ERRORS = [
      Pipedrive::Error::Unauthorized,
    ].freeze

    include PipedriveAppLogger

    def initialize(authorization)
      @authorization = authorization
    end

    def authorization_client
      @authorization_client ||= Pipedrive::Authorization.new(
        ENV['PIPEDRIVE_CLIENT_ID'],
        ENV['PIPEDRIVE_CLIENT_SECRET'],
      )
    end

    def unauthorized?(response)
      response.code == 401
    end

    def log_response(response)
      log_info(
        type: 'http_request',
        status: response.code,
        body: response.body,
        target: 'pipedrive',
      )
    end

    def log_request(resource, payload)
      log_info(
        type: 'http_request',
        resource: resource,
        payload: payload,
        target: 'pipedrive',
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
