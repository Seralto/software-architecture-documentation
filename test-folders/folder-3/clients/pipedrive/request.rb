module Pipedrive
  class Request
    def initialize(authorization)
      @authorization = authorization
    end

    def get(resource, params = {})
      encoded_params = URI.encode_www_form(params)
      path = encoded_params.blank? ? resource : "#{resource}?#{encoded_params}"
      http_client.get(url_for(path), headers: auth_header)
    end

    def post(resource, body)
      http_client.post(url_for(resource), headers: auth_header, body: body)
    end

    def delete(resource, id)
      http_client.delete("#{url_for(resource)}/#{id}", headers: auth_header)
    end

    def put(resource, id, body)
      http_client.put("#{url_for(resource)}/#{id}", headers: auth_header, body: body)
    end

    private

    def url_for(resource)
      "https://api-proxy.pipedrive.com/#{resource}"
    end

    def auth_header
      { 'Authorization' => "Bearer #{@authorization.access_token}" }
    end

    def http_client
      HTTParty
    end
  end
end
