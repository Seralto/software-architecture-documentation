module EventProcessor
  module RequestLogger
    def log_event_processing(payload)
      log_info(
        event_type: self.class.const_get(:EVENT_TYPE),
        status: Event::Status::PROCESSING,
        account_id: @account_id,
        field_combination: @field_combination,
        event_payload: payload,
      )
    end

    def log_response_success(response)
      log_info(
        event_type: self.class.const_get(:EVENT_TYPE),
        status: Event::Status::PROCESSED,
        account_id: @account_id,
        field_combination: @field_combination,
        event_payload: payload,
        response: response,
      )
    end

    def log_response_error(response)
      log_error(
        event_type: self.class.const_get(:EVENT_TYPE),
        status: Event::Status::ERROR,
        account_id: @account_id,
        field_combination: @field_combination,
        event_payload: payload,
        response: response,
      )
    end
  end
end
