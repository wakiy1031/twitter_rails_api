# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def index
        limit = (params[:limit] || 50).to_i
        offset = (params[:offset] || 0).to_i

        posts = Post.all
                    .includes(:user)
                    .order(created_at: :desc)
                    .limit(limit)
                    .offset(offset)

        render json: posts.as_json(
          methods: :created_at,
          current_user: current_api_v1_user
        )
      end

      def show
        post = Post.find(params[:id])
        render json: { data: post.as_json(current_user: current_api_v1_user, include: { images: { only: %i[id filename content_type byte_size] } }) }
      rescue ActiveRecord::RecordNotFound
        render json: { message: '投稿が見つかりませんでした。' }, status: :not_found
      end

      def create
        post = current_api_v1_user.posts.build(post_params)
        if post.save
          render json: { data: post }, status: :created
        else
          render json: { message: '投稿失敗しました。', errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def upload_images
        images = params.require(:images)

        return render status: :no_content if images.empty?

        post = find_post(params[:post_id])
        return unless post

        blobs = post.attach_images(images)

        if blobs.any?
          render json: { data: blobs }
        else
          render json: { message: '画像登録失敗しました。' }, status: :unprocessable_entity
        end
      end

      def destroy
        post = Post.find(params[:id])
        post.destroy
        render json: { message: '投稿を削除しました。' }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { message: '投稿が見つかりませんでした。' }, status: :not_found
      end

      private

      def post_params
        params.require(:post).permit(:content)
      end

      def find_post(post_id)
        post = Post.find_by(id: post_id)
        render json: { message: '画像登録先の投稿が見つかりませんでした。' }, status: :unprocessable_entity unless post
        post
      end
    end
  end
end
