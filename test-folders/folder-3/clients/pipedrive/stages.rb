module Pipedrive
  class Stages < Client
    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def all
      request do
        response = pipedrive_request.get('stages')
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        parsed_body['data']
      end
    end

    private

    def pipedrive_request
      @pipedrive_request ||= Pipedrive::Request.new(@authorization)
    end
  end
end
