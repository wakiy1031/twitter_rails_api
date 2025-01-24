# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  validates :action, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  VALID_ACTIONS = %w[like follow comment].freeze
  validates :action, inclusion: { in: VALID_ACTIONS }

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def read?
    read_at.present?
  end

  def self.mark_as_read_by_recipient(recipient)
    where(recipient: recipient, read_at: nil).update_all(read_at: Time.current)
  end
end
