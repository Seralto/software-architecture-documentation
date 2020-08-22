module RdstationClient
  class Contacts < Client
    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def upsert(identifier, identifier_value, contact_hash)
      request do
        contacts.upsert(identifier, identifier_value, contact_hash)
      end
    end

    private

    def contacts
      RDStation::Client.new(access_token: @authorization.access_token).contacts
    end
  end
end
