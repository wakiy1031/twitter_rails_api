module Api
  module V1
    class UsersController < ApplicationController
      def show
        user = User.find(params[:id])
        render json: {
          name: user.name,
          email: user.email,
          user_name: user.user_name,
          place: user.place,
          description: user.description,
          website: user.website,
          id: user.id,
          posts_count: user.posts.count,
          tweets: user.posts.order(created_at: :desc),
          avatar_url: user.avatar_image.attached? ? url_for(user.avatar_image) : nil,
          is_self: user.id == current_api_v1_user&.id
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      def update_profile
        if current_api_v1_user.update(user_params)
          render json: {
            name: current_api_v1_user.name,
            email: current_api_v1_user.email,
            user_name: current_api_v1_user.user_name,
            place: current_api_v1_user.place,
            description: current_api_v1_user.description,
            website: current_api_v1_user.website,
            id: current_api_v1_user.id,
            avatar_url: current_api_v1_user.avatar_image.attached? ? url_for(current_api_v1_user.avatar_image) : nil,
            is_self: true
          }
        else
          render json: { errors: current_api_v1_user.errors }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :user_name, :description, :place, :website, :header_image, :avatar_image)
      end
    end
  end
end
