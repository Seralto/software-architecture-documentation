class SessionsController < ApplicationController
  def new
    query_params = { redirect_to: auth_callback_url }
    redirect_to "#{auth_service_url}?#{query_params.to_query}"
  end

  def create
    token = params[:id_token]
    session[:user_info] = Auth0::Toolkit::UserAuthentication.verify(token)
    redirect_to select_account_path
  end

  def logout_callback
    session[:user_info] = nil
    session[:account_id] = nil
    redirect_to login_path
  end

  private

  def auth_service_url
    @auth_service_url ||= ENV['AUTH_SERVICE_URL']
  end

  def auth_callback_url
    @auth_callback_url ||= ENV['AUTH_CALLBACK_URL']
  end
end
