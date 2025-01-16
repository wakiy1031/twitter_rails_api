# frozen_string_literal: true

module UserResponseFormatter
  extend ActiveSupport::Concern

  private

  def format_user_comments(user)
    user.comments.includes(:post, :user)
        .order(created_at: :desc)
        .map { |comment| format_comment_with_post(comment) }
  end

  def format_comment_with_post(comment)
    {
      id: comment.id,
      content: comment.content,
      created_at: format_time_ago(comment.created_at),
      images: format_comment_images(comment),
      post: format_related_post(comment.post)
    }
  end

  def format_comment_images(comment)
    comment.images.map { |image| format_single_image(image) }
  end

  def format_single_image(image)
    {
      id: image.id,
      filename: image.filename.to_s,
      content_type: image.content_type,
      byte_size: image.byte_size,
      url: generate_image_url(image)
    }
  end

  def format_related_post(post)
    {
      id: post.id,
      content: post.content,
      created_at: format_time_ago(post.created_at),
      user: format_post_user(post.user)
    }
  end

  def format_post_user(user)
    user.as_json(only: %i[id name]).merge(
      'avatar_url' => user.send(:generate_attachment_url, user.avatar_image)
    )
  end

  def format_time_ago(time)
    "#{ActionController::Base.helpers.time_ago_in_words(time)}前"
  end

  def generate_image_url(image)
    Rails.application.routes.url_helpers.rails_blob_url(
      image,
      only_path: true,
      host: 'localhost:3000'
    )
  end
end
