# frozen_string_literal: true

module ProjectParser
  class ClassStructureService
    def initialize(name, type)
      @name = name
      @type = type
      @public_methods = []
      @class_methods = []
    end

    def add_public_method(method_name)
      @public_methods.push(method_name)
    end

    def add_class_method(method_name)
      @class_methods.push(method_name)
    end
  end
end
