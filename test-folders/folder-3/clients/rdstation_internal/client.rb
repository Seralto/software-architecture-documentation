module RdstationInternal
  class Client
    DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }.freeze

    class << self
      def get(context, path, headers = DEFAULT_HEADERS)
        connection.get(context, path, {}, headers) do |request|
          sign_request(request)
        end
      end

      def post(context, path, headers = DEFAULT_HEADERS)
        connection.post(context, path, nil, headers) do |request|
          sign_request(request)
        end
      end

      def connection
        Mstk::Rest::Client.new(url: ENV['RDSTATION_INTERNAL_API_URL'])
      end

      def sign_request(request)
        ApiAuth.sign!(
          request,
          ENV['APP_NAME'],
          ENV['RDSTATION_INTERNAL_API_SECRET'],
          digest: 'SHA256',
        )
      end
    end

    private_class_method :connection, :sign_request
  end
end
