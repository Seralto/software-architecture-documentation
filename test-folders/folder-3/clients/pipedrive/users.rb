module Pipedrive
  class Users < Client
    RESOURCE = 'users'.freeze

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def by_email(email)
      request do
        query_params = {
          term: email,
          search_by_email: 1,
        }
        endpoint = "#{RESOURCE}/find"
        response = pipedrive_request.get(endpoint, query_params)
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        parsed_body
      end
    end

    def me
      request do
        endpoint = "#{RESOURCE}/me"
        response = pipedrive_request.get(endpoint)
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        parsed_body
      end
    end

    private

    def pipedrive_request
      @pipedrive_request ||= Pipedrive::Request.new(@authorization)
    end
  end
end
