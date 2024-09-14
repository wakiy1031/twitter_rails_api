module Api
  module V1
    module Users
      class RegistrationsController < DeviseTokenAuth::RegistrationsController
        private

        def sign_up_params
          params.permit(:name, :email, :phone, :birthdate, :password, :password_confirmation)
        end
      end
    end
  end
end
