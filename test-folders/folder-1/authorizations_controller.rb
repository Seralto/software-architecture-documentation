class AuthorizationsController < ApplicationController
  def deauthorize_app
    DisconnectionService.new(account_id: current_account.id, disconnection_type: params[:type]).disconnect
  rescue RDStation::Error::InternalServerError, Pipedrive::Error::InternalServerError => error
    notify_exception error
  ensure
    redirect_to root_url
  end

  def failure
    redirect_to '/pipedrive/authorize'
  end

  private

  def notify_exception(error)
    extra = {
      account_id: current_account.id,
      account_name: current_account.name,
      account_platform_account_id: current_account.platform_account_id,
      disconnection_type: params[:type],
    }
    Rollbar.error(error, 'MoTeam-PipedriveApp-AppDeauthorization', extra)
  end
end
