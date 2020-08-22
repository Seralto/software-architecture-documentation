module RdstationClient
  class ContactEvents < Client
    include PipedriveAppLogger

    ENDPOINT_URL = 'https://api.rd.services/platform/contacts'.freeze

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def last_event_identifier(contact_uuid)
      request do
        response = HTTParty.get(url(contact_uuid), headers: auth_header)
        response_body = RDStation::ApiResponse.build(response)
        return response_body[0]['event_identifier'] unless response_body.empty?
      end
    rescue RDStation::Error::NotFound => error
      log_error(error: error.to_s, contact_uuid: contact_uuid)
      return
    end

    private

    def auth_header
      { 'Authorization' => "Bearer #{@authorization.access_token}" }
    end

    def url(contact_uuid)
      ENDPOINT_URL + "/" + contact_uuid + "/events?" + query_params.to_param
    end

    def query_params
      { 
          'event_type' => 'CONVERSION',
          'order' => 'created_at:desc',
          'page' => '1',
          'per_page' => '1'
      }
    end
  end
end
