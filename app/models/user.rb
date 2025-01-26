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
  has_many :comments, dependent: :destroy
  has_many :reposts, dependent: :destroy
  has_many :reposted_posts, through: :reposts, source: :post
  has_many :favorites, dependent: :destroy
  has_many :favorited_posts, through: :favorites, source: :post

  # 通知関連
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient

  # フォロー関連
  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent: :destroy,
                                  inverse_of: :follower
  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy,
                                   inverse_of: :followed
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  def follow(other_user)
    return false if self == other_user

    following << other_user
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def as_json(options = {})
    super(options.except(:current_user)).tap do |hash|
      hash.merge!(attachment_urls)
      if options[:current_user].present?
        hash.merge!(
          is_following: options[:current_user].following?(self),
          is_self: options[:current_user] == self
        )
      end
    end
  end

  private

  def attachment_urls
    {
      'avatar_url' => generate_attachment_url(avatar_image),
      'header_image_url' => generate_attachment_url(header_image)
    }
  end

  def generate_attachment_url(attachment)
    return unless attachment.attached?

    Rails.application.routes.url_helpers.rails_storage_proxy_url(
      attachment,
      only_path: false,
      host: 'localhost:3000'
    )
  end
end
