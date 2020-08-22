module Pipedrive
  class Webhooks < Client
    attr_reader :authorization

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def by_subscription_url(url)
      all.find { |webhook| webhook['subscription_url'] == url }
    end

    def create(payload)
      request do
        response = pipedrive_request.post('webhooks', payload)
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        parsed_body
      end
    end

    def delete(uuid)
      request do
        response = pipedrive_request.delete('webhooks', uuid)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)
      end
    end

    def all
      request do
        response = pipedrive_request.get('webhooks')
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        parsed_body['data']
      end
    end

    private

    def pipedrive_request
      @pipedrive_request ||= Pipedrive::Request.new(@authorization)
    end
  end
end
