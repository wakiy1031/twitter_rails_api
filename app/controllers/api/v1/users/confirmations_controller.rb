# frozen_string_literal: true

module Api
  module V1
    module Users
      class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
      end
    end
  end
end
