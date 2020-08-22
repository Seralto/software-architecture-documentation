module RdstationClient
  class Webhooks < Client
    attr_reader :authorization

    def initialize(authorization)
      @authorization = authorization
      super(authorization)
    end

    def by_uuid(uuid)
      webhooks.by_uuid(uuid)
    end

    def create(webhooks_payload)
      request { webhooks.create(webhooks_payload) }
    end

    def delete(uuid)
      request { webhooks.delete(uuid) }
    end

    private

    def webhooks
      RDStation::Client.new(access_token: @authorization.access_token).webhooks
    end
  end
end
