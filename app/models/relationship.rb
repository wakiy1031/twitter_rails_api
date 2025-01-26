# frozen_string_literal: true

class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validate :not_follow_self

  after_create :create_notification

  private

  def not_follow_self
    errors.add(:base, '自分自身をフォローすることはできません') if follower_id == followed_id
  end

  def create_notification
    Notification.create!(
      recipient: followed,
      notifiable: self,
      action: 'follow'
    )
  end
end
