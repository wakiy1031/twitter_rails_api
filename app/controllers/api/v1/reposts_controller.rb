module Api
  module V1
    class RepostsController < ApplicationController
      before_action :set_post

      def create
        repost = current_api_v1_user.reposts.build(post: @post)

        if repost.save
          render json: {
            message: 'リポストしました。',
            repost_count: @post.reposts.count
          }, status: :created
        else
          render json: {
            message: 'リポストに失敗しました。',
            errors: repost.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        repost = current_api_v1_user.reposts.find_by!(post: @post)
        repost.destroy
        render json: {
          message: 'リポストを取り消しました。',
          repost_count: @post.reposts.count
        }
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'リポストが見つかりません。' }, status: :not_found
      end

      private

      def set_post
        @post = Post.find(params[:tweet_id])
      rescue ActiveRecord::RecordNotFound
        render json: { message: '投稿が見つかりません。' }, status: :not_found
      end
    end
  end
end
