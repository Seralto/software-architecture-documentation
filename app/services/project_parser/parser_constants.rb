# frozen_string_literal: true

module ProjectParser
  module ParserConstants
    MODULE_REGEX = /^\s*module\s([A-z\d]*)/.freeze
    CLASS_REGEX = /^\s*class\s(?!<)([A-z\d]*)/.freeze
    PUBLIC_METHOD_REGEX = /^\s*def\s(?!self\.)([a-z_]*)/.freeze
    CLASS_METHOD_REGEX = /^\s*def\sself\.([a-z_]*)/.freeze
    PRIVATE_PROTECTED_REGEX = /(private|protected)\s/.freeze
    CLASS_METHOD_DEFINITION_REGEX = /^\s*class\s<<\sself/.freeze
    IDENTATION_LEVEL_REGEX = /\A\s*/.freeze
  end
end
