class EventType < ApplicationRecord
  has_many :events

  RD_CONVERSION = 'WEBHOOK.CONVERTED'.freeze
  RD_OPPORTUNITY = 'WEBHOOK.MARKED_OPPORTUNITY'.freeze
  PIPEDRIVE_UPDATED_DEAL = 'updated.deal'.freeze

  def rd_conversion?
    rd_identifier == RD_CONVERSION
  end
end
