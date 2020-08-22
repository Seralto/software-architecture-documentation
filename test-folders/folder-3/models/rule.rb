class Rule < ApplicationRecord
  belongs_to :integration
  belongs_to :trigger, dependent: :destroy
  has_many :actions_rules, dependent: :delete_all
  has_many :actions, through: :actions_rules
end
