# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ApplicationController
      include RoomResponseFormatter
      before_action :authenticate_api_v1_user!
      before_action :set_room

      def index
        messages = @room.messages.includes(:user).order(created_at: :desc)
        render json: messages.map { |message| message_response(message) }
      end

      def create
        message = build_message
        if message.save
          render json: message_response(message), status: :created
        else
          render json: { errors: message.errors }, status: :unprocessable_entity
        end
      end

      private

      def message_response(message)
        {
          id: message.id,
          content: message.content,
          created_at: message.created_at.strftime('%Y年%m月%d日 %H:%M'),
          user: user_response(message.user)
        }
      end

      def user_response(user)
        {
          id: user.id,
          name: user.name,
          avatar_url: user.avatar_image.attached? ? url_for(user.avatar_image) : nil
        }
      end

      def build_message
        @room.messages.build(message_params).tap do |message|
          message.user = current_api_v1_user
        end
      end

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
