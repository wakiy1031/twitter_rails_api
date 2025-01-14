# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      def show
        user = User.find(params[:id])
        render json: user_show_response(user), status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      def update_profile
        handle_image_removal
        if current_api_v1_user.update(user_params)
          render json: user_response_json(current_api_v1_user)
        else
          render json: { errors: current_api_v1_user.errors }, status: :unprocessable_entity
        end
      end

      private

      def handle_image_removal
        current_api_v1_user.header_image.purge if remove_header_image?
        current_api_v1_user.avatar_image.purge if remove_avatar_image?
      end

      def remove_header_image?
        params[:user][:remove_header_image] == 'true' && current_api_v1_user.header_image.attached?
      end

      def remove_avatar_image?
        params[:user][:remove_avatar_image] == 'true' && current_api_v1_user.avatar_image.attached?
      end

      def user_params
        params.require(:user).permit(
          :name, :user_name, :description, :place,
          :website, :header_image, :avatar_image
        )
      end

      def user_show_response(user)
        {
          **base_user_attributes(user),
          posts_count: user.posts.count,
          tweets: user.posts.order(created_at: :desc),
          comments: user.comments.includes(:post, :user).order(created_at: :desc).map { |comment|
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
              post: {
                id: comment.post.id,
                content: comment.post.content,
                created_at: "#{ActionController::Base.helpers.time_ago_in_words(comment.post.created_at)}前",
                user: comment.post.user.as_json(only: %i[id name]).merge(
                  'avatar_url' => comment.post.user.send(:generate_attachment_url, comment.post.user.avatar_image)
                )
              }
            }
          },
          is_self: user.id == current_api_v1_user&.id,
          created_at: user.created_at.strftime('%Y年%-m月')
        }
      end

      def user_response_json(user)
        {
          **base_user_attributes(user),
          is_self: true
        }
      end

      def base_user_attributes(user)
        {
          name: user.name,
          email: user.email,
          user_name: user.user_name,
          place: user.place,
          description: user.description,
          website: user.website,
          id: user.id,
          avatar_url: attachment_url(user.avatar_image),
          header_image_url: attachment_url(user.header_image)
        }
      end

      def attachment_url(attachment)
        attachment.attached? ? url_for(attachment) : nil
      end
    end
  end
end
