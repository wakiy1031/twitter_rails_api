# frozen_string_literal: true

module UserAttributesFormatter
  extend ActiveSupport::Concern

  private

  def base_user_attributes(user)
    {
      name: user.name,
      email: user.email,
      user_name: user.user_name,
      place: user.place,
      description: user.description,
      website: user.website,
      id: user.id,
      avatar_url: attachment_url(user.avatar_image),
      header_image_url: attachment_url(user.header_image)
    }
  end

  def attachment_url(attachment)
    attachment.attached? ? url_for(attachment) : nil
  end
end
