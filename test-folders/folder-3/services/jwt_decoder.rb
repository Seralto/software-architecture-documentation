class JwtDecoder
  def initialize(token)
    @token = token
  end

  def decode
    decoded_token_array = JWT.decode(@token, nil, false)
    decoded_token_array.first
  end
end
