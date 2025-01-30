# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_room, only: [:show]
      include UserStatsFormatter


      def index
        rooms = current_api_v1_user.rooms.where(group: false).includes(:users)
        render json: rooms.map { |room|
          other_user = room.users.where.not(id: current_api_v1_user.id).first
          {
            id: room.id,
            other_user: {
              id: other_user.id,
              name: other_user.name,
              email: other_user.email,
              avatar_url: other_user.avatar_image.attached? ? url_for(other_user.avatar_image) : nil,
              created_at: other_user.created_at.strftime('%Y年%-m月'),
              description: other_user.description,
              followers_count: other_user.followers.count,
            },
            last_message: room.messages.last&.then { |message|
              {
                content: message.content,
                created_at: message.created_at.strftime('%Y年%m月%d日')
              }
            },
            created_at: room.created_at.strftime('%Y年%m月%d日')
          }
        }
      end

      def show
        other_user = @room.users.where.not(id: current_api_v1_user.id).first
        render json: {
          id: @room.id,
          other_user: {
            id: other_user.id,
            name: other_user.name,
            avatar_url: other_user.avatar_image.attached? ? url_for(other_user.avatar_image) : nil
          },
          messages: @room.messages.includes(:user).order(created_at: :desc).map { |message|
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
        }
      end

      def create
        other_user = User.find(params[:user_id])

        # 既存の1対1のチャットルームを探す
        existing_room = Room.joins(:entries)
                          .where(group: false)
                          .where(entries: { user_id: [current_api_v1_user.id, other_user.id] })
                          .group('rooms.id')
                          .having('COUNT(DISTINCT entries.user_id) = 2')
                          .first

        if existing_room
          render json: {
            id: existing_room.id,
            other_user: {
              id: other_user.id,
              name: other_user.name,
              avatar_url: other_user.avatar_image.attached? ? url_for(other_user.avatar_image) : nil
            },
            created_at: existing_room.created_at.strftime('%Y年%m月%d日')
          }, status: :ok
          return
        end

        room = Room.new(group: false)

        if room.save
          # 両ユーザーをルームに追加
          room.entries.create!(user: current_api_v1_user)
          room.entries.create!(user: other_user)

          render json: {
            id: room.id,
            other_user: {
              id: other_user.id,
              name: other_user.name,
              avatar_url: other_user.avatar_image.attached? ? url_for(other_user.avatar_image) : nil
            },
            created_at: room.created_at.strftime('%Y年%m月%d日')
          }, status: :created
        else
          render json: { errors: room.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      private

      def set_room
        @room = current_api_v1_user.rooms.where(group: false).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'チャットルームが見つかりません' }, status: :not_found
      end
    end
  end
end
