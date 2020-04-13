# frozen_string_literal: true

module ProjectParser
  class FileParserService
    include ParserConstants

    def initialize(project_hierarchy)
      @project_hierarchy = project_hierarchy
      @parent_entity = nil
      @current_entity = nil
      @class_method_definition = false
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
      find_entity(line) || find_class_method_definition(line) || find_methods(line)
    end

    def find_entity(line)
      entity_name, type = find_module(line) || find_class(line)
      return unless entity_name

      find_identation_level(line)
      insert_entity(entity_name, type) unless entity_already_exists?(entity_name)

      update_parent_entity
    end

    def find_module(line)
      module_name = line.match(MODULE_REGEX)
      [module_name[1], 'module'] if module_name
    end

    def find_class(line)
      class_name = line.match(CLASS_REGEX)
      [class_name[1], 'class'] if class_name
    end

    def find_identation_level(line)
      @indentation_level = line[IDENTATION_LEVEL_REGEX].size / 2
    end

    def insert_entity(entity_name, type)
      @current_entity = class_structure(entity_name, type)

      if @indentation_level.zero?
        @project_hierarchy.push(@current_entity)
      else
        @parent_entity.add_hierarchy(@current_entity)
      end
    end

    def entity_already_exists?(entity_name)
      if @indentation_level.zero? && @project_hierarchy.map(&:name).include?(entity_name)
        @current_entity = @project_hierarchy.find { |entity| entity.name == entity_name }
        return true
      elsif @parent_entity&.already_has_entity_in_hierarchy(entity_name)
        @current_entity = @parent_entity.hierarchy.find { |entity| entity.name == entity_name }
        return true
      end

      false
    end

    def update_parent_entity
      @parent_entity = @current_entity
    end

    def find_class_method_definition(line)
      class_method_definition = line.match(CLASS_METHOD_DEFINITION_REGEX)
      @class_method_definition = true if class_method_definition
    end

    def find_methods(line)
      method, type = find_public_method(line) || find_class_method(line)
      return unless method

      type = :class if @class_method_definition
      insert_method(method, type)
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

    def insert_method(method, type)
      @current_entity.send("add_#{type}_method", method)
    end

    def class_structure(name, type)
      ProjectParser::ClassStructureService.new(name, type)
    end
  end
end
