class DisconnectionService
  class Type
    TYPE_PIPEDRIVE = 'AuthorizationPipedrive'.freeze
    TYPE_RDSTATION = 'AuthorizationRdstation'.freeze

    def initialize(type)
      @type = type
    end

    def rdstation?
      @type == TYPE_RDSTATION
    end

    def pipedrive?
      @type == TYPE_PIPEDRIVE
    end

    def raw
      @type
    end
  end
end
