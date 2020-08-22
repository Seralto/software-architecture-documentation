class Authorization < ApplicationRecord
  belongs_to :account

  scope :rdstation, -> { where(type: 'AuthorizationRdstation') }
  scope :pipedrive, -> { where(type: 'AuthorizationPipedrive') }

  def update_credentials(credentials)
    new_credentials = credentials.with_indifferent_access
    self.access_token = new_credentials[:access_token]
    self.refresh_token = new_credentials[:refresh_token]
    save
  end
end
