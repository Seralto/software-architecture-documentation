module Api
  module V1
    class EventsController < AccountTokenProtectedController
      def all
        json_events = events.to_json(except: %i[created_at updated_at])
        render json: json_events, status: :ok
      end

      private

      def events
        @events ||= Event.all
      end
    end
  end
end
