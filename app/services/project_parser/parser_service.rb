# frozen_string_literal: true

module ProjectParser
  class ParserService
    class << self
      def parse
        files.map do |file|
          file_parser.parse(file)
        end
      end

      private

      def files
        Dir.glob('./tmp/folders/**/*.rb')
      end

      def file_parser
        ProjectParser::FileParserService.new
      end
    end
  end
end
