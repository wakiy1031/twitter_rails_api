# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def show
        post = Post.find(params[:id])
        render json: { data: post.as_json(include: { images: { only: %i[id filename content_type byte_size] } }) }
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

        blobs = create_and_attach_blobs(post, images)

        if blobs.any?
          render json: { data: blobs }
        else
          render json: { message: '画像登録失敗しました。' }, status: :unprocessable_entity
        end
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

      def create_and_attach_blobs(post, images)
        images.map do |image|
          blob = ActiveStorage::Blob.create_and_upload!(
            io: image,
            filename: image.original_filename,
            content_type: image.content_type
          )
          post.images.attach(blob.signed_id)
          blob
        end
      end
    end
  end
end
