module RdstationInternal
  class PipedriveNotifications
    def by_account(context, platform_account_id)
      response = client.get(context, notification_path(platform_account_id))
      parsed_response = JSON.parse(response.body)
      raise StandardError.new, parsed_response['errors'].first['error_message'] if parsed_response['errors']

      parsed_response
    end

    def skip_enqueue(context, platform_account_id)
      response = client.post(context, skip_enqueue_path(platform_account_id))
      response.status == 200
    end

    private

    def client
      RdstationInternal::Client
    end

    def notification_path(platform_account_id)
      "/api/internal/v1/accounts/#{platform_account_id}/pipedrive_notifications"
    end

    def skip_enqueue_path(platform_account_id)
      "/api/internal/v1/accounts/#{platform_account_id}/pipedrive_notifications/skip_enqueue"
    end
  end
end
