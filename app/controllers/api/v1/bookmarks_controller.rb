# frozen_string_literal: true

module Api
  module V1
    class BookmarksController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_post, only: %i[create destroy]

      def index
        bookmarks = current_api_v1_user.bookmarked_posts
                                       .includes(:user, :comments, :favorites, :reposts, images_attachments: :blob)
                                       .order('bookmarks.created_at DESC')

        render json: bookmarks.map { |post| post.as_json(current_user: current_api_v1_user) }
      end

      def create
        bookmark = current_api_v1_user.bookmarks.build(post: @post)

        if bookmark.save
          render json: {
            message: 'ブックマークに追加しました',
            bookmarks_count: @post.bookmarks.count,
            bookmarked: true
          }, status: :created
        else
          render json: {
            message: 'ブックマークの追加に失敗しました',
            errors: bookmark.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        bookmark = current_api_v1_user.bookmarks.find_by!(post: @post)
        bookmark.destroy
        render json: {
          message: 'ブックマークを解除しました',
          bookmarks_count: @post.bookmarks.count,
          bookmarked: false
        }
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'ブックマークが見つかりません' }, status: :not_found
      end

      private

      def set_post
        @post = Post.find(params[:tweet_id])
      rescue ActiveRecord::RecordNotFound
        render json: { message: '投稿が見つかりません' }, status: :not_found
      end
    end
  end
end
