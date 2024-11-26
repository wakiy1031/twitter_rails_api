# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User

  validates :name, presence: true, length: { maximum: 15 }, uniqueness: true
  validates :email, presence: true, format: { with: /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/ }
  validates :phone, presence: true, format: { with: /\A\d{10}$|^\d{11}\z/ }
  validates :birthdate, presence: true
  validates :user_name, presence: true, on: :update
  validates :user_name, uniqueness: true, allow_nil: true

  has_many :posts, dependent: :destroy
  has_one_attached :avatar_image
  has_one_attached :header_image
end
