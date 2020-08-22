class AuthorizationInfo
  def initialize(authorization)
    @authorization = authorization
  end

  def to_hash
    {
      'authorized' => authorized?,
      'account' => account_name,
    }
  end

  private

  attr_reader :authorization

  def authorized?
    authorization.present?
  end

  def account_name
    return unless authorized?

    authorization.platform_account_name
  end
end
