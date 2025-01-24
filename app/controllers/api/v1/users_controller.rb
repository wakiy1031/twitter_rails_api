# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include UserResponseFormatter
      include TweetResponseFormatter
      include UserStatsFormatter
      include UserAttributesFormatter

      def show
        user = User.find(params[:id])
        render json: user_show_response(user), status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      def update_profile
        handle_image_removal
        if current_api_v1_user.update(user_params)
          render json: user_response_json(current_api_v1_user)
        else
          render json: { errors: current_api_v1_user.errors }, status: :unprocessable_entity
        end
      end

      private

      def handle_image_removal
        current_api_v1_user.header_image.purge if remove_header_image?
        current_api_v1_user.avatar_image.purge if remove_avatar_image?
      end

      def remove_header_image?
        params[:user][:remove_header_image] == 'true' && current_api_v1_user.header_image.attached?
      end

      def remove_avatar_image?
        params[:user][:remove_avatar_image] == 'true' && current_api_v1_user.avatar_image.attached?
      end

      def user_params
        params.require(:user).permit(
          :name, :user_name, :description, :place,
          :website, :header_image, :avatar_image
        )
      end

      def user_show_response(user)
        {
          **base_user_attributes(user),
          **user_stats(user),
          **user_content(user),
          is_self: user.id == current_api_v1_user&.id,
          created_at: user.created_at.strftime('%Y年%-m月')
        }
      end

      def user_response_json(user)
        {
          **base_user_attributes(user),
          is_self: true
        }
      end
    end
  end
end
