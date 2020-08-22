class Trigger < ApplicationRecord
  has_many :rules
  belongs_to :event
  has_many :actions, through: :rules
end
