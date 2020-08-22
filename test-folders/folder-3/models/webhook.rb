class Webhook < ApplicationRecord
  belongs_to :integration
  belongs_to :event_type, optional: true
end
