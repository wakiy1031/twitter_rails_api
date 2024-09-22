# frozen_string_literal: true

module Api
  module V1
    module Auth
      class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
        protected

        def after_confirmation_path_for(_resource_name, _resource)
          'http://localhost:3001/signin'
        end

        def redirect_to(options = {}, response_options = {})
          if Rails.env.production?
            super(options, response_options)
          else
            super(options, response_options.merge(allow_other_host: true))
          end
        end
      end
    end
  end
end
