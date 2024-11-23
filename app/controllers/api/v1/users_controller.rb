module Api
  module V1
    class UsersController < ApplicationController
      def show
        user = User.find(params[:id])
        render json: {
          tweets: user.posts.order(created_at: :desc)
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end
    end
  end
end
