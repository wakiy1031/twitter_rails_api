# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many_attached :images

  validates :content, presence: true, length: { maximum: 140 }

  after_create :create_notification

  def as_json(options = {})
    super(options).tap do |hash|
      hash.merge!(
        images: format_images,
        user: format_user
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

  def create_notification
    # 自分の投稿に対する他人のコメントの場合のみ通知を作成
    return if user_id == post.user_id # 自分の投稿へのコメント
    return if post.user_id != user_id # 他人の投稿へのコメント

    Notification.create!(
      recipient: post.user,
      notifiable: self,
      action: 'comment'
    )
  end

  def format_images
    images.map do |image|
      {
        id: image.id,
        filename: image.filename.to_s,
        content_type: image.content_type,
        byte_size: image.byte_size,
        url: generate_image_url(image)
      }
    end
  end

  def format_user
    user.as_json(only: %i[id name email]).merge(
      'avatar_url' => user.send(:generate_attachment_url, user.avatar_image),
      'header_image_url' => user.send(:generate_attachment_url, user.header_image)
    )
  end

  def generate_image_url(image)
    Rails.application.routes.url_helpers.rails_blob_url(
      image,
      only_path: true,
      host: 'localhost:3000'
    )
  end
end
