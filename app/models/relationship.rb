# frozen_string_literal: true

class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validate :not_follow_self

  private

  def not_follow_self
    errors.add(:base, '自分自身をフォローすることはできません') if follower_id == followed_id
  end
end
