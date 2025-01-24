# frozen_string_literal: true

module Api
  module V1
    class FollowsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_user

      def create
        if @user == current_api_v1_user
          return render json: { error: '自分自身をフォローすることはできません' },
                        status: :unprocessable_entity
        end

        if current_api_v1_user.follow(@user)
          render json: { message: 'フォローしました' }, status: :ok
        else
          render json: { error: 'フォローに失敗しました' }, status: :unprocessable_entity
        end
      end

      def destroy
        if current_api_v1_user.unfollow(@user)
          render json: { message: 'フォロー解除しました' }, status: :ok
        else
          render json: { error: 'フォロー解除に失敗しました' }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end
    end
  end
end
