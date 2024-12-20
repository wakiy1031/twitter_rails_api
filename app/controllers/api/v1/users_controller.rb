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
          tweets: user.posts.order(created_at: :desc)
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      def update_profile
        if current_api_v1_user.update(user_params)
          render json: current_api_v1_user
        else
          render json: { errors: current_api_v1_user.errors }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :user_name, :description, :place, :website)
      end
    end
  end
end
