# frozen_string_literal: true

module ProjectParser
  class ParserService
    def initialize
      @project_hierarchy = []
    end

    def parse
      files.map do |file|
        file_parser.parse(file)
      end

      @project_hierarchy
    end

    private

    def files
      # Dir.glob('./tmp/folders-old/event_parser/pipedrive/won_deal.rb')
      # Dir.glob('./tmp/folders-old/test.rb')
      # Dir.glob('./tmp/folders-old/**/*.rb')
      Dir.glob('./tmp/folders/**/*.rb')
    end

    def file_parser
      ProjectParser::FileParserService.new(@project_hierarchy)
    end
  end
end
