module RdstationClient
  class Authorization
    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
    end

    def refresh_access_token(_context, refresh_token)
      client.update_access_token(refresh_token)
    end

    class << self
      def retryable_revoke(context:, authorization:)
        RDStation::Authentication.revoke(access_token: authorization.access_token)
      rescue RDStation::Error::InternalServerError => error
        extra = { authorization: authorization }
        Rollbar.error(error, 'MoTeam-PipedriveApp-RdstationClient-Authorization', extra)
        raise error
      rescue RDStation::Error::Unauthorized
        begin
          refresh_access_token(context, authorization)
          RDStation::Authentication.revoke(access_token: authorization.access_token)
        rescue RDStation::Error::InvalidCredentials
          # already revoked
        end
      end

      private

      def refresh_access_token(context, authorization)
        auth_client = RdstationClient::Authorization.new(ENV['RDSTATION_CLIENT_ID'], ENV['RDSTATION_CLIENT_SECRET'])
        new_credentials = auth_client.refresh_access_token(context, authorization.refresh_token)
        authorization.update_credentials(new_credentials)
      end
    end

    private

    attr_reader :client_id, :client_secret

    def client
      RDStation::Authentication.new(client_id, client_secret)
    end
  end
end
