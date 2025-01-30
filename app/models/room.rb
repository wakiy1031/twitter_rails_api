# frozen_string_literal: true

class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :users, through: :entries

  validates :name, presence: true, if: :group?

  # グループチャットの場合のみ名前とオーナーを必須にする
  def group?
    group == true
  end
end
