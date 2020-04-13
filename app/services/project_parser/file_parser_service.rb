# frozen_string_literal: true

module ProjectParser
  class FileParserService
    include ParserConstants

    def initialize(project_hierarchy)
      @project_hierarchy = project_hierarchy
    end

    def parse(filename)
      file = File.open(filename, 'r')
      file.each_line do |line|
        private_or_protected_keyword_found = line.match(PRIVATE_PROTECTED_REGEX)
        break if private_or_protected_keyword_found

        parse_line(line)
      end
      file.close
    end

    private

    def parse_line(line)
      find_identation_level(line)
      find_entity(line)
      find_public_methods(line)
    end

    def find_identation_level(line)
      @level = line[IDENTATION_LEVEL_REGEX].size / 2
    end

    def find_entity(line)
      entity, type = find_module(line) || find_class(line)
      return unless entity

      insert_entity(entity, type) if ENTITY_TYPES.include?(type)
    end

    def find_module(line)
      module_name = line.match(MODULE_REGEX)
      [module_name[1], 'module'] if module_name
    end

    def find_class(line)
      class_name = line.match(CLASS_REGEX)
      [class_name[1], 'class'] if class_name
    end

    def find_public_methods(line)
      method, type = find_class_method_definition(line) || find_public_method(line) || find_class_method(line)
      return unless method

      insert_method(method, type)
    end

    def find_class_method_definition(line)
      class_method_definition = line.match(CLASS_METHOD_DEFINITION_REGEX)
      @class_method_definition = true if class_method_definition
    end

    def find_class_method(line)
      class_method = line.match(CLASS_METHOD_REGEX)
      [class_method[1], :class] if class_method
    end

    def find_public_method(line)
      public_method = line.match(PUBLIC_METHOD_REGEX)
      return unless public_method && public_method[1] != 'initialize'

      [public_method[1], :public]
    end

    def insert_entity(entity, type)
      if @level.zero?
        return if @project_hierarchy.map(&:name).include?(entity)

        @project_hierarchy.push(class_structure(entity, type))
        return
      end

      structure = find_structure_in_level
      return if structure.already_has_entity_in_hierarchy(entity)

      structure.add_hierarchy(class_structure(entity, type))
    end

    def insert_method(method, type)
      if @level.zero?
        @project_hierarchy.send("add_#{type}_method", method)
        return
      end

      structure = find_structure_in_level

      structure.send("add_#{type}_method", method)
    end

    def find_structure_in_level
      structure = @project_hierarchy.first
      (@level - 1).times do
        structure = structure.hierarchy.first
      end
      structure
    end

    def class_structure(name, type)
      ProjectParser::ClassStructureService.new(name, type)
    end
  end
end
