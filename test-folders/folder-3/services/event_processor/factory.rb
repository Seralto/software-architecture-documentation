module EventProcessor
  class Factory
    def self.get_instance(integration, actions, payload, actions_rules = [])
      account = integration.account

      case integration.type
      when 'rdstation_to_pipedrive'
        EventProcessor::RdstationToPipedrive.new(account, actions, payload, actions_rules)
      when 'pipedrive_to_rdstation'
        EventProcessor::PipedriveToRdstation.new(account, actions, payload)
      else
        raise ArgumentError, 'Invalid integration type'
      end
    end
  end
end
