module EnrichPayloadService
  extend self
  
  def perform(payload, account_id)
    stringify_keys(payload)
    use_contact_email_when_contact_name_is_blank(payload)
    use_contact_name_when_company_name_is_blank(payload)
    inject_event_identifier_into_contact(payload, account_id)
    payload
  end

  private

  def stringify_keys(payload)
    payload.each do |key, value|
      if value.is_a?(Hash)
        stringify_keys(value)
      elsif value.is_a?(Array)
        payload[key] = value.join(', ')
      else
        payload[key] = value.to_s
      end
    end
  end

  def use_contact_email_when_contact_name_is_blank(payload)
    contact = payload['contact']
    return payload unless contact

    contact['name'] = contact['email'] if contact['name'].blank?
  end

  def use_contact_name_when_company_name_is_blank(payload)
    contact = payload['contact']
    return payload unless contact

    contact['company']['name'] = contact['name'] if contact['company']['name'].blank?
  end

  # TODO: create a proper abstraction for RDSM payload. event_identifier is not an attribute of contact.
  def inject_event_identifier_into_contact(payload, account_id)
    contact = payload['contact']
    return payload unless contact

    contact['event_identifier'] = last_event_identifier(contact['uuid'], payload, account_id)
  end

  def last_event_identifier(contact_uuid, payload, account_id)
    if rd_opportunity?(payload)      
      client = contact_events(account_id)
      event_identifier = client.last_event_identifier(contact_uuid)
      return event_identifier if event_identifier.present?
    end

    payload['event_identifier']
  end

  def rd_opportunity?(payload)
    payload['event_type'] == EventType::RD_OPPORTUNITY
  end

  def rdstation_authorization(account_id)
    AuthorizationRdstation.find_by(account_id: account_id)
  end

  def contact_events(account_id)
    RdstationClient::ContactEvents.new(rdstation_authorization(account_id))
  end
end
