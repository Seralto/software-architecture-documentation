class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_account
  before_action :set_locale

  def current_account
    @current_account ||= begin
      account_id = session[:account_id]
      return unless account_id

      Account.find_by(id: account_id)
    end
  end

  def rdstation_authorization
    return unless current_account

    @rdstation_authorization ||= AuthorizationRdstation.find_by(account_id: current_account.id)
  end

  def pipedrive_authorization
    return unless current_account

    @pipedrive_authorization ||= AuthorizationPipedrive.find_by(account_id: current_account.id)
  end

  def set_locale
    session[:locale] = params[:locale] if params[:locale].present?
    I18n.locale = session[:locale] || I18n.default_locale
  end
end
