module EventProcessor
  class ErrorHandling
    RETRYABLES_CODES = [
      408,
      429,
      500,
      502,
      503,
      504,
      506,
      507,
      508,
      510,
      511,
      599,
    ].freeze

    def self.retry(code)
      raise EventProcessor::Error::HttpRequest, "HTTP Error Code: #{code}" if RETRYABLES_CODES.include?(code)
    end
  end
end
