module Pipedrive
  class Organizations < Client
    RESOURCE = 'organizations'.freeze

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def create(payload)
      request do
        response = pipedrive_request.post('organizations', payload)
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        parsed_body
      end
    end

    def update(id, payload)
      request do
        response = pipedrive_request.put('organizations', id, payload)
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        parsed_body
      end
    end

    def by_name(name)
      request do
        endpoint = "#{RESOURCE}/find"
        response = pipedrive_request.get(endpoint, term: name)
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
