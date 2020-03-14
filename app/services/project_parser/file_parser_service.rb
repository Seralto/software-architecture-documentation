# frozen_string_literal: true

module ProjectParser
  class FileParserService
    MODULE_REGEX = /^\s*module\s([A-z\d]*)/.freeze
    CLASS_REGEX = /^\s*class\s(?!<)([A-z\d]*)/.freeze
    METHOD_REGEX = /^\s*def\s(?!self\.)([a-z_]*)/.freeze
    CLASS_METHOD_REGEX = /^\s*def\sself\.([a-z_]*)/.freeze
    PRIVATE_PROTECTED_REGEX = /(private|protected)\s/.freeze
    CLASS_METHOD_DEFINITION_REGEX = /^\s*class\s<<\sself/.freeze

    def initialize
      @class_hierarchy = []
    end

    def parse(filename)
      file = File.open(filename, 'r')
      file.each_line do |line|
        deadline = line.match(PRIVATE_PROTECTED_REGEX)
        break if deadline

        parse_line(line)
      end
      file.close

      @class_hierarchy
    end

    private

    def parse_line(line)
      find_module(line)
      find_class(line)
      find_class_method_definition(line)
      find_method(line)
      find_class_method(line)
    end

    def find_module(line)
      module_name = line.match(MODULE_REGEX)
      @class_hierarchy.push(class_structure(module_name[1], 'module')) if module_name
    end

    def find_class(line)
      class_name = line.match(CLASS_REGEX)
      @class_hierarchy.push(class_structure(class_name[1])) if class_name
    end

    def find_class_method_definition(line)
      class_method_definition = line.match(CLASS_METHOD_DEFINITION_REGEX)
      @class_method_definition = true if class_method_definition
    end

    def find_class_method(line)
      class_method = line.match(CLASS_METHOD_REGEX)
      @class_hierarchy.last.add_class_method(class_method[1]) if class_method
    end

    def find_method(line)
      method = line.match(METHOD_REGEX)
      return if method.nil? || method[1] == 'initialize'

      add_method(method[1])
    end

    def add_method(method)
      if @class_method_definition
        @class_hierarchy.last.add_class_method(method)
      else
        @class_hierarchy.last.add_public_method(method)
      end
    end

    def class_structure(name, type = 'class')
      ProjectParser::ClassStructureService.new(name, type)
    end
  end
end
