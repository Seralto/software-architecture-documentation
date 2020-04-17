class AccountsController < ApplicationController
  layout 'common'

  def edit
    @user_email = user_email
    @authorized_platform_accounts = account_options_for_select
  end

  def create
    account = create_account
    session[:account_id] = account.id
    redirect_to controller: :app, action: :index
  end

  private

  def create_account
    @create_account ||= Account.find_or_create_by(platform_account_id: selected_account[:id]) do |account|
      account.name = selected_account[:name]
    end
  end

  def selected_account
    id, name = account_params[:platform_account].split(':')
    { id: id, name: name }
  end

  def account_params
    params.permit(:platform_account)
  end

  def user_email
    session['user_info']['email']
  end

  def account_options_for_select
    platform_accounts.map { |account| [account[:name], "#{account[:id]}:#{account[:name]}"] }
  end

  def platform_accounts
    @platform_accounts ||= Platform::AuthorizationService.get_authorized_platform_accounts_for(user_email)
  end
end
