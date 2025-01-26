# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :messages, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :users, through: :entries

  validates :name, presence: true, if: :group?
  validates :group, inclusion: { in: [true, false] }

  # グループチャットの場合のみ名前を必須にする
  def group?
    group == true
  end
end
