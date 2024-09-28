class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  validates :content, presence: true, length: { maximum: 140 }

  def as_json(options = {})
    super(options).tap do |hash|
      hash['images'] = images.map do |image|
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
end
