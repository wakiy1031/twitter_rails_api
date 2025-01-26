# frozen_string_literal: true

class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }

  after_create :create_notification

  private

  def create_notification
    # 自分の投稿に対する他人のリポストの場合のみ通知を作成
    return if user_id == post.user_id # 自分の投稿へのリポスト

    Notification.create!(
      recipient: post.user,
      notifiable: self,
      action: 'repost'
    )
  end
end
