class Account < ApplicationRecord
  has_many :authorizations, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :rules, through: :integrations
  has_one :field_combination, dependent: :destroy

  after_create :generate_field_combination, :generate_token, :generate_integrations

  def reset_field_combination
    field_combination.delete
    generate_field_combination
  end

  private

  def generate_token
    token_string = "#{name}#{Time.zone.now}#{SecureRandom.base64(32)}"
    self.token = Digest::MD5.hexdigest(token_string)
    save
  end

  def generate_field_combination
    self.field_combination = FieldCombination.new(mapping: FieldCombination::DEFAULT_MAPPING)
    save
  end

  def generate_integrations
    integrations.create(type: :pipedrive_to_rdstation)
    integrations.create(type: :rdstation_to_pipedrive)
  end
end
