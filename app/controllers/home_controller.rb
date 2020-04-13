# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @hierarchy = parser_service.parse
    render json: @hierarchy
  end

  private

  def parser_service
    ProjectParser::ParserService.new
  end
end
