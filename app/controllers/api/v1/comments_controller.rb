module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_post, only: [:index]

      def index
        comments = @post.comments.includes(:user).order(created_at: :desc)
        render json: comments.map { |comment|
          {
            id: comment.id,
            content: comment.content,
            created_at: "#{ActionController::Base.helpers.time_ago_in_words(comment.created_at)}前",
            images: comment.images.map do |image|
              {
                id: image.id,
                filename: image.filename.to_s,
                content_type: image.content_type,
                byte_size: image.byte_size,
                url: Rails.application.routes.url_helpers.rails_blob_url(
                  image,
                  only_path: true,
                  host: 'localhost:3000'
                )
              }
            end,
            user: comment.user.as_json(only: %i[id name email]).merge(
              'avatar_url' => comment.user.send(:generate_attachment_url, comment.user.avatar_image)
            )
          }
        }
      end

      def create
        comment = current_api_v1_user.comments.build(comment_params)
        if comment.save
          render json: { data: comment }, status: :created
        else
          render json: { message: 'コメント失敗しました。', errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def upload_images
        comment = Comment.find(params[:id])
        images = params.require(:images)

        return render status: :no_content if images.empty?

        blobs = comment.attach_images(images)

        if blobs.any?
          render json: { data: blobs }
        else
          render json: { message: '画像登録失敗しました。' }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'コメントが見つかりませんでした。' }, status: :not_found
      end

      def destroy
      end

      private

      def comment_params
        params.require(:comment).permit(:content, :post_id)
      end

      def set_post
        @post = Post.find(params[:tweet_id])
      rescue ActiveRecord::RecordNotFound
        render json: { message: '投稿が見つかりませんでした。' }, status: :not_found
      end

    end
  end
end
