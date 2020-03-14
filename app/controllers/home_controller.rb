# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @hierarchy = ProjectParser::ParserService.parse
    render json: @hierarchy
  end
end
