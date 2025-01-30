# frozen_string_literal: true

module RoomResponseFormatter
  extend ActiveSupport::Concern

  private

  def room_list_response(room)
    other_user = find_other_user_in_room(room)
    {
      id: room.id,
      other_user: other_user_response(other_user),
      last_message: last_message_response(room.messages.last),
      created_at: room.created_at.strftime('%Y年%m月%d日')
    }
  end

  def room_detail_response(room)
    other_user = find_other_user_in_room(room)
    {
      id: room.id,
      other_user: other_user_response(other_user),
      messages: room.messages.includes(:user).order(created_at: :desc).map do |message|
        message_response(message)
      end
    }
  end

  def other_user_response(user)
    {
      id: user.id,
      name: user.name,
      avatar_url: user.avatar_image.attached? ? url_for(user.avatar_image) : nil
    }
  end

  def message_response(message)
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
  end

  def last_message_response(message)
    return nil unless message

    {
      content: message.content,
      created_at: message.created_at.strftime('%Y年%m月%d日')
    }
  end

  def find_other_user_in_room(room)
    room.users.where.not(id: current_api_v1_user.id).first
  end
end
