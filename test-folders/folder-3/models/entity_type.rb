class EntityType < ApplicationRecord
  has_many :events
  has_many :field_combinations
end
