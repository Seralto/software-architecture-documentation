module Api
  module V1
    class EventListenersController < ApplicationController
      include PipedriveAppLogger

      before_action :ensure_permitted_events, only: :listener

      skip_before_action :verify_authenticity_token

      def listener
        context = build_context(integration_uuid)
        log_info(msg: 'event received', integration_uuid: integration_uuid, event_payload: event_payload)
        EventMatchingJob.perform_async(context, integration_uuid, event_payload)
        head :accepted
      end

      private

      def build_context(integration_uuid)
        Mstk::Context.create(nil, integration_uuid: integration_uuid)
      end

      def event_payload
        @event_payload ||= ActiveSupport::JSON.decode(request.body.string)
      end

      def integration_uuid
        params[:integration_uuid]
      end

      def ensure_permitted_events
        head :unprocessable_entity unless permitted_events?
      end

      def permitted_events?
        event_payload['event_type'] == EventType::RD_CONVERSION ||
          event_payload['event_type'] == EventType::RD_OPPONTUNITY ||
          event_payload['event'] == EventType::PIPEDRIVE_UPDATED_DEAL
      end
    end
  end
end
