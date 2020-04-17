# frozen_string_literal: true

module Api
  module V1
    class HierarchiesController < ApplicationController
      def index
        @hierarchy = parser_service.parse
        render json: @hierarchy
      end

      private

      def parser_service
        ProjectParser::ParserService.new
      end
    end
  end
end
