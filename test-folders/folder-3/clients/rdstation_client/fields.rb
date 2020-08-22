module RdstationClient
  class Fields < Client
    attr_reader :authorization

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def all
      request { fields.all }
    end

    private

    def fields
      RDStation::Client.new(access_token: @authorization.access_token).fields
    end
  end
end
