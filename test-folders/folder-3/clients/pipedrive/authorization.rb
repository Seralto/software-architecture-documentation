module Pipedrive
  class Authorization
    TOKEN_URL = 'https://oauth.pipedrive.com/oauth/token'.freeze
    REVOKE_URL = 'https://oauth.pipedrive.com/oauth/revoke'.freeze
    DEFAULT_HEADERS = { 'Content-Type' => 'application/x-www-form-urlencoded' }.freeze

    ERRORS_MAPPING = {
      'Invalid client: client is invalid' => Pipedrive::Error::InvalidClient,
      'Invalid grant: refresh token is invalid' => Pipedrive::Error::InvalidRefreshToken,
    }.freeze

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
    end

    def refresh_access_token(context, refresh_token)
      request_body = {
        grant_type: 'refresh_token',
        refresh_token: refresh_token,
      }

      Mstk::Logger.info(context, request_log_params(request_body))

      response = auth_request(
        grant_type: 'refresh_token',
        refresh_token: refresh_token,
      )

      Mstk::Logger.info(context, response_log_params(response))

      response_body = JSON.parse(response.body)
      success, message = response_body.values_at('success', 'message')
      return raise ERRORS_MAPPING[message] if success == false

      response_body
    end

    # this uninstalls the app. See https://pipedrive.readme.io/docs/app-uninstallation#section-token-revocation
    def revoke(refresh_token:)
      response = HTTParty.post(
        REVOKE_URL,
        body: { token: refresh_token, token_type_hint: 'refresh_token' },
        headers: basic_auth_header.merge(DEFAULT_HEADERS),
      )
      raise Pipedrive::Error::InternalServerError if response.code == 500
    end

    private

    def auth_request(body)
      HTTParty.post(
        TOKEN_URL,
        body: body,
        headers: request_headers,
      )
    end

    def request_log_params(request_body)
      {
        type: 'HTTP_REQUEST',
        request_url: TOKEN_URL,
        request_headers: request_headers,
        request_body: request_body,
      }
    end

    def response_log_params(response)
      {
        type: 'HTTP_RESPONSE',
        request_url: TOKEN_URL,
        response_headers: request_headers,
        response_body: response.body,
        status: response.code,
      }
    end

    def request_headers
      basic_auth_header.merge(DEFAULT_HEADERS)
    end

    def basic_auth_header
      { 'Authorization' => "Basic #{encoded_basic_auth}" }
    end

    def encoded_basic_auth
      @encoded_basic_auth ||= Base64.urlsafe_encode64("#{@client_id}:#{@client_secret}")
    end
  end
end
