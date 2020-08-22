module Pipedrive
  class Persons < Client
    RESOURCE = 'persons'.freeze

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def by_id(id)
      request do
        person_endpoint = "#{RESOURCE}/#{id}"
        response = pipedrive_request.get(person_endpoint)
        log_response(response)
        parsed_body = JSON.parse(response.body)
        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)
        parsed_body
      end
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

    def create(payload)
      request do
        log_request(RESOURCE, payload)
        response = pipedrive_request.post(RESOURCE, payload)
        log_response(response)

        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)

        # NOTE: Add this validation because Pipedrive is returning 'Not Found' in some POST requests
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          {}
        end
      end
    end

    def update(id, payload)
      request do
        log_request(RESOURCE, id: id, payload: payload)
        response = pipedrive_request.put(RESOURCE, id, payload)
        log_response(response)

        raise Pipedrive::Error::Unauthorized if unauthorized?(response)

        ::EventProcessor::ErrorHandling.retry(response.code)

        # NOTE: Add this validation because Pipedrive is returning 'Not Found' in some PUT requests
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          {}
        end
      end
    end

    private

    def pipedrive_request
      @pipedrive_request ||= Pipedrive::Request.new(@authorization)
    end
  end
end
