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
          header_image_url: user.header_image.attached? ? url_for(user.header_image) : nil,
          is_self: user.id == current_api_v1_user&.id,
          created_at: user.created_at.strftime("%Y年%-m月")
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      def update_profile
        # 画像の削除処理
        if params[:user][:remove_header_image] == "true"
          current_api_v1_user.header_image.purge if current_api_v1_user.header_image.attached?
        end

        # アバター画像の削除処理
        if params[:user][:remove_avatar_image] == "true"
          current_api_v1_user.avatar_image.purge if current_api_v1_user.avatar_image.attached?
        end

        # 新しい画像のアップロードを含む通常の更新処理
        if current_api_v1_user.update(user_params)
          render json: user_response_json(current_api_v1_user)
        else
          render json: { errors: current_api_v1_user.errors }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(
          :name,
          :user_name,
          :description,
          :place,
          :website,
          :header_image,
          :avatar_image
        )
      end

      def user_response_json(user)
        {
          name: user.name,
          email: user.email,
          user_name: user.user_name,
          place: user.place,
          description: user.description,
          website: user.website,
          id: user.id,
          avatar_url: user.avatar_image.attached? ? url_for(user.avatar_image) : nil,
          header_image_url: user.header_image.attached? ? url_for(user.header_image) : nil,
          is_self: true
        }
      end
    end
  end
end
