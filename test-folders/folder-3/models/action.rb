class Action < ApplicationRecord
  belongs_to :event
  has_many :actions_rules
  has_many :rules, through: :actions_rules
  accepts_nested_attributes_for :actions_rules
end
