module RdstationInternal
  class Users
    def by_account(context, account_id)
      response = client.get(context, path(account_id))
      return unless response.status == 200

      JSON.parse(response.body)
    end

    private

    def client
      RdstationInternal::Client
    end

    def path(account_id)
      "/api/internal/v1/accounts/#{account_id}/users"
    end
  end
end
