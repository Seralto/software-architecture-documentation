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
      # Dir.glob('./test-folders/folder-1/**/*.rb')
      # Dir.glob('./test-folders/folder-2/**/*.rb')
      Dir.glob('./test-folders/folder-3/**/*.rb')
    end

    def file_parser
      ProjectParser::FileParserService.new(@project_hierarchy)
    end
  end
end
