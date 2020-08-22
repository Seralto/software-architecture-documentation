module Pipedrive
  class Deals < Client
    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def create(payload)
      request do
        response = pipedrive_request.post('deals', payload)
        log_response(response)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        response
      end
    end

    private

    def pipedrive_request
      @pipedrive_request ||= Pipedrive::Request.new(@authorization)
    end
  end
end
