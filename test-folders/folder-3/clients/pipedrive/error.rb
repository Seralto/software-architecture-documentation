module Pipedrive
  module Error
    class InvalidClient < StandardError; end
    class InvalidRefreshToken < StandardError; end
    class InvalidClientInstance < StandardError; end
    class Unauthorized < StandardError; end
    class InternalServerError < StandardError; end
  end
end
