# frozen_string_literal: true

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: {
    scope: :post_id,
    message: :already_favorited
  }

  after_create :create_notification

  private

  def create_notification
    # 自分の投稿に対する他人のいいねの場合のみ通知を作成
    return if user_id == post.user_id # 自分の投稿へのいいね
    return if post.user_id != user_id # 他人の投稿へのいいね

    Notification.create!(
      recipient: post.user,
      notifiable: self,
      action: 'like'
    )
  end
end
