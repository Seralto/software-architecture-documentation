module Authorizations
  class RdstationController < ApplicationController
    def callback
      return redirect_to root_url if create_authorization

      flash[:error] = 'Invalid access credentials'
      redirect_to login_url
    end

    private

    def authorization_data
      @authorization_data ||= request.env['omniauth.auth']
    end

    def credentials
      @credentials ||= authorization_data.credentials
    end

    def authorization
      @authorization ||= AuthorizationRdstation.find_or_initialize_by(account_id: account.id)
    end

    def account
      @account ||= Account.find_by(id: session[:account_id])
    end

    def create_authorization
      authorization.access_token = credentials['token']
      authorization.refresh_token = credentials['refresh_token']
      authorization.platform_account_name = authorization_data.info['account_name']
      authorization.save
    end
  end
end
