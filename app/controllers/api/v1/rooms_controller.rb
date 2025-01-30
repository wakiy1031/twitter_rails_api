# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      include RoomResponseFormatter
      before_action :authenticate_api_v1_user!
      before_action :set_room, only: [:show]

      def index
        rooms = current_api_v1_user.rooms.where(group: false).includes(:users)
        render json: rooms.map { |room| room_list_response(room) }
      end

      def show
        render json: room_detail_response(@room)
      end

      def create
        other_user = find_other_user
        existing_room = find_existing_room(other_user)

        if existing_room
          render json: room_list_response(existing_room), status: :ok
          return
        end

        create_new_room(other_user)
      end

      private

      def find_other_user
        User.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
        raise
      end

      def find_existing_room(other_user)
        Room.joins(:entries)
            .where(group: false)
            .where(entries: { user_id: [current_api_v1_user.id, other_user.id] })
            .group('rooms.id')
            .having('COUNT(DISTINCT entries.user_id) = 2')
            .first
      end

      def create_new_room(other_user)
        room = Room.new(group: false)

        if room.save
          create_room_entries(room, other_user)
          render json: room_list_response(room), status: :created
        else
          render json: { errors: room.errors }, status: :unprocessable_entity
        end
      end

      def create_room_entries(room, other_user)
        room.entries.create!(user: current_api_v1_user)
        room.entries.create!(user: other_user)
      end

      def set_room
        @room = current_api_v1_user.rooms.where(group: false).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'チャットルームが見つかりません' }, status: :not_found
      end
    end
  end
end
