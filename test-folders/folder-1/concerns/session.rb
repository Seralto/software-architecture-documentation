module Session
  extend ActiveSupport::Concern

  included do
    helper_method :user_signed_in?
  end

  def user_signed_in?
    user_info = session[:user_info]
    user_info.present? && valid_session_token?(user_info)
  end

  def valid_session_token?(current_session)
    Auth0::Toolkit::UserAuthentication.verify(current_session['credentials']['id_token'])
  rescue JWT::ExpiredSignature, JWT::InvalidIssuerError
    session[:user_info] = nil
    false
  end
end
