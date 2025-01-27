# frozen_string_literal: true

module Api
  module V1
    class GroupMessagesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_group
      before_action :ensure_group_member

      def create
        message = @group.messages.build(message_params)
        message.user = current_api_v1_user

        if message.save
          render json: {
            id: message.id,
            content: message.content,
            created_at: message.created_at,
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

      def set_group
        @group = Room.where(group: true).find(params[:group_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'グループが見つかりません' }, status: :not_found
      end

      def ensure_group_member
        unless @group.users.include?(current_api_v1_user)
          render json: { error: 'グループのメンバーではありません' }, status: :forbidden
        end
      end

      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end
