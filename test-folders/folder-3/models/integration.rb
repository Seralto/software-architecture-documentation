class Integration < ApplicationRecord
  belongs_to :account
  has_many :rules, dependent: :destroy
  has_many :triggers, through: :rules

  enum type: { pipedrive_to_rdstation: 0, rdstation_to_pipedrive: 1 }

  def self.inheritance_column
    nil
  end

  def rdstation_to_pipedrive?
    type == 'rdstation_to_pipedrive'
  end

  def pipedrive_to_rdstation?
    type == 'pipedrive_to_rdstation'
  end
end
