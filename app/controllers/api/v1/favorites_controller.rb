module Api::V1
  class FavoritesController < ApplicationController
    before_action :set_post

    def create
      favorite = current_api_v1_user.favorites.build(post: @post)

      if favorite.save
        render json: {
          message: 'いいねしました。',
          favorite_count: @post.favorites.count,
          favorited: true
        }, status: :created
      else
        render json: {
          message: 'いいねに失敗しました。',
          errors: favorite.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def destroy
      favorite = current_api_v1_user.favorites.find_by!(post: @post)
      favorite.destroy
      render json: {
        message: 'いいねを取り消しました。',
        favorite_count: @post.favorites.count,
        favorited: false
      }
    rescue ActiveRecord::RecordNotFound
      render json: { message: 'いいねが見つかりません。' }, status: :not_found
    end

    private

    def set_post
      @post = Post.find(params[:tweet_id])
    rescue ActiveRecord::RecordNotFound
      render json: { message: '投稿が見つかりません。' }, status: :not_found
    end
  end
end
