module Api
  module V1
    class CommentsController < ApplicationController

      def index
      end

      def create
        comment = current_api_v1_user.comments.build(comment_params)
        if comment.save
          render json: { data: comment }, status: :created
        else
          render json: { message: 'コメント失敗しました。', errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
      end

      private

      def comment_params
        params.require(:comment).permit(:content, :post_id)
      end

    end
  end
end
