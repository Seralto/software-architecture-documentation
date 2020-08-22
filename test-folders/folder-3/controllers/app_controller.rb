class AppController < ApplicationController
  def index
    @custom_csrf_token = form_authenticity_token
  end
end
