# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_room

      def index
        messages = @room.messages.includes(:user).order(created_at: :desc)
        render json: messages.map { |message|
          {
            id: message.id,
            content: message.content,
            created_at: message.created_at.strftime('%Y年%m月%d日 %H:%M'),
            user: {
              id: message.user.id,
              name: message.user.name,
              avatar_url: message.user.avatar_image.attached? ? url_for(message.user.avatar_image) : nil
            }
          }
        }
      end

      def create
        message = @room.messages.build(message_params)
        message.user = current_api_v1_user

        if message.save
          render json: {
            id: message.id,
            content: message.content,
            created_at: message.created_at.strftime('%Y年%m月%d日 %H:%M'),
            user: {
              id: message.user.id,
              name: message.user.name,
              avatar_url: message.user.avatar_image.attached? ? url_for(message.user.avatar_image) : nil
            }
          }, status: :created
        else
          render json: { errors: message.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_room
        @room = current_api_v1_user.rooms.find(params[:room_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'チャットルームが見つかりません' }, status: :not_found
      end

      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end
