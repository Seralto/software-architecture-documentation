module RdstationClient
  class EventIdentifiers < Client
    ENDPOINT_URL = 'https://api.rd.services/platform/event_identifiers'.freeze

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def all
      request do
        response = HTTParty.get(ENDPOINT_URL, headers: auth_header)
        response_body = RDStation::ApiResponse.build(response)
        response_body['event_identifiers'].map { |e| { value: e['identifier'], label: e['title'] } }
      end
    end

    private

    def auth_header
      { 'Authorization' => "Bearer #{@authorization.access_token}" }
    end
  end
end
