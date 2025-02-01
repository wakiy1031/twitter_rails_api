# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: {
    scope: :post_id,
    message: :already_bookmarked
  }
end
