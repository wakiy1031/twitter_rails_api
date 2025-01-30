# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :content, presence: true, length: { maximum: 140 }

  # メッセージ送信者がルームのメンバーであることを確認
  validate :user_must_be_room_member

  private

  def user_must_be_room_member
    return if room.users.include?(user)

    errors.add(:base, 'ルームのメンバーではありません')
  end
end
