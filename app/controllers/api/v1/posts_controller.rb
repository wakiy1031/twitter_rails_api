class Api::V1::PostsController < ApplicationController
  def create
    post = current_api_v1_user.posts.build(post_params)
    if post.save
      render json: { data: post }, status: :created
    else
      render json: { message: '投稿失敗しました。', errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end
  private

  def post_params
    params.require(:post).permit(:content)
  end
end
