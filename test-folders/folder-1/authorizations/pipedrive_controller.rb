module Authorizations
  class PipedriveController < ApplicationController
    def callback
      return redirect_to(root_url) if update_authorization

      flash[:error] = 'Invalid access credentials'
      redirect_to login_url
    end

    def deauthorize
      destroyed = authorization&.destroy if authorization.persisted?
      flash[:error] = 'Error when deauthorize Pipedrive' unless destroyed
      redirect_to root_url
    end

    private

    def authorization_data
      @authorization_data ||= request.env['omniauth.auth']
    end

    def credentials
      @credentials ||= authorization_data['credentials']
    end

    def authorization
      @authorization ||= AuthorizationPipedrive.find_or_initialize_by(
        account_id: current_account.id,
      )
    end

    def update_authorization
      authorization.update(
        access_token: credentials['token'],
        refresh_token: credentials['refresh_token'],
        platform_account_name: authorization_data['info']['name'],
        account_id: current_account.id,
      )
    end
  end
end
