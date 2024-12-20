# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  validates :content, presence: true, length: { maximum: 140 }

  def as_json(options = {})
    super(options).tap do |hash|
      hash['images'] = image_data
      hash['user'] = user.as_json(only: %i[name id user_name place description website email])
      hash['created_at'] = "#{ActionController::Base.helpers.time_ago_in_words(created_at)}前"
      hash['post_create'] = I18n.l(created_at, format: :post_create)
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
end
