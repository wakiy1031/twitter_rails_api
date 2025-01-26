# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }

  VALID_ACTIONS = %w[like follow comment repost].freeze
  validates :action, inclusion: { in: VALID_ACTIONS }
end
