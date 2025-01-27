# frozen_string_literal: true

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        room = Room.new(group_params.merge(group: true, owner: current_api_v1_user))

        if room.save
          # グループ作成者を最初のメンバーとして追加
          room.entries.create!(user: current_api_v1_user)

          render json: {
            id: room.id,
            name: room.name,
            owner: {
              id: room.owner.id,
              name: room.owner.name
            },
            created_at: room.created_at
          }, status: :created
        else
          render json: { errors: room.errors }, status: :unprocessable_entity
        end
      end

      private

      def group_params
        params.require(:group).permit(:name)
      end
    end
  end
end
