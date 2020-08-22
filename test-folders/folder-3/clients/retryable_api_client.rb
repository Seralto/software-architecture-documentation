class RetryableApiClient
  attr_reader :authorization, :client

  def initialize(context, authorization, client)
    @authorization = authorization
    @client = client
    @retries = 0
    @max_retries = 1
    @context = context
  end

  def request
    yield
  rescue *client.class::RETRYABLE_AUTHORIZATION_ERRORS
    if @retries < @max_retries
      @retries += 1
      refresh_credentials
      retry
    end
  end

  protected

  def refresh_credentials
    refresh_authorization_on_database
    refresh_authorization_on_client
  end

  private

  def refresh_authorization_on_database
    new_credentials = authorization_client.refresh_access_token(@context, authorization.refresh_token)
    authorization.update_credentials(new_credentials)
  end

  def refresh_authorization_on_client
    client.authorization = authorization
  end

  def authorization_client
    client.authorization_client
  end
end
