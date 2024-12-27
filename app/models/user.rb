# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules...
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User

  validates :name, presence: true, length: { maximum: 15 }, uniqueness: true
  validates :email, presence: true, format: { with: /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/ }
  validates :phone, presence: true, format: { with: /\A\d{10}$|^\d{11}\z/ }
  validates :birthdate, presence: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

  has_many :posts, dependent: :destroy
  has_one_attached :avatar_image
  has_one_attached :header_image

  def as_json(options = {})
    super(options).tap do |hash|
      if avatar_image.attached?
        hash['avatar_url'] = Rails.application.routes.url_helpers.rails_storage_proxy_url(
          avatar_image,
          only_path: false,
          host: 'localhost:3000'
        )
      else
        hash['avatar_url'] = nil
      end

      if header_image.attached?
        hash['header_image_url'] = Rails.application.routes.url_helpers.rails_storage_proxy_url(
          header_image,
          only_path: false,
          host: 'localhost:3000'
        )
      else
        hash['header_image_url'] = nil
      end
    end
  end
end
