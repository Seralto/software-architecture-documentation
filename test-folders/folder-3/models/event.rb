class Event < ApplicationRecord
  belongs_to :event_type
  belongs_to :entity_type

  enum category: { trigger: 0, action: 1 }
  enum integration_type: { pipedrive_to_rdstation: 0, rdstation_to_pipedrive: 1 }

  scope :deal_won, -> { find_by(description: 'deal_won') }
  scope :deal_lost, -> { find_by(description: 'deal_lost') }
  scope :mark_as_sale, -> { find_by(description: 'mark_as_sale') }
  scope :opportunity_lost, -> { find_by(description: 'opportunity_lost') }
end
