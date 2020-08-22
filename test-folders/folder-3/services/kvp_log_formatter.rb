# frozen_string_literal: true

class KVPLogFormatter
  class << self
    def info(hash)
      message = format(hash)
      ::Rails.logger.info message
    end

    def error(hash)
      message = format(hash)
      ::Rails.logger.error message
    end

    def format(hash)
      Mstk::LogFormatter.format(hash)
    end
  end
end
