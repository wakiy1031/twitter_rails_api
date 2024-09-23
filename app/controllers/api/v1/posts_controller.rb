class Api::V1::PostsController < ApplicationController
  def create
    render json: { message: '投稿完了' }
  end
end
