# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  validates :content, presence: true, length: { maximum: 140 }
  has_many :comments, dependent: :destroy
  has_many :reposts, dependent: :destroy
  has_many :reposted_posts, through: :reposts, source: :post

  def as_json(options = {})
    super(options).tap do |hash|
      hash.merge!(
        images: image_data,
        user: format_user,
        created_at: format_created_at,
        post_create: format_post_create,
        comments: format_comments,
        comments_count: comments.size,
        repost_count: reposts.size,
        reposted: options[:current_user].present? ? options[:current_user].reposts.exists?(post_id: id) : false
      )
    end
  end

  def attach_images(images)
    images.map do |image|
      blob = ActiveStorage::Blob.create_and_upload!(
        io: image,
        filename: image.original_filename,
        content_type: image.content_type
      )
      self.images.attach(blob.signed_id)
      blob
    end
  end

  private

  def image_data
    images.map do |image|
      {
        id: image.id,
        filename: image.filename.to_s,
        content_type: image.content_type,
        byte_size: image.byte_size,
        url: Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
      }
    end
  end

  def format_user
    user.as_json(only: %i[name id user_name place description website email avatar_url])
  end

  def format_created_at
    "#{ActionController::Base.helpers.time_ago_in_words(created_at)}前"
  end

  def format_post_create
    I18n.l(created_at, format: :post_create)
  end

  def format_comments
    comments.includes(:user).order(created_at: :desc).map do |comment|
      comment.as_json.merge(
        user: comment.user.as_json(only: %i[id name]).merge(
          'avatar_url' => comment.user.send(:generate_attachment_url, comment.user.avatar_image)
        )
      )
    end
  end
end
