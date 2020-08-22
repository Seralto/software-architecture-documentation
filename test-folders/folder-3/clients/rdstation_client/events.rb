module RdstationClient
  class Events < Client
    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def create(event_payload)
      request do
        events.create(event_payload) || {}
      end
    end

    private

    def events
      RDStation::Client.new(access_token: @authorization.access_token).events
    end
  end
end
