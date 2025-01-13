class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many_attached :images

  validates :content, presence: true
  validates :post_id, presence: true

  def as_json(options = {})
    super(options).tap do |hash|
      hash['images'] = images.map do |image|
        {
          id: image.id,
          filename: image.filename.to_s,
          content_type: image.content_type,
          byte_size: image.byte_size,
          url: Rails.application.routes.url_helpers.rails_blob_url(
            image,
            only_path: true,
            host: 'localhost:3000'
          )
        }
      end
      hash['user'] = user.as_json(only: %i[id name email]).merge(
        'avatar_url' => user.send(:generate_attachment_url, user.avatar_image),
        'header_image_url' => user.send(:generate_attachment_url, user.header_image)
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
end
