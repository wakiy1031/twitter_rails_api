# frozen_string_literal: true

module TweetResponseFormatter
  extend ActiveSupport::Concern

  private

  def format_user_tweets(user)
    posts = user.posts.or(Post.where(id: user.reposts.pluck(:post_id)))
                .order(created_at: :desc)

    posts.map do |post|
      format_tweet(post, user)
    end
  end

  def format_tweet(post, user)
    repost = user.reposts.find_by(post:)
    post.as_json(current_user: current_api_v1_user)
        .merge(
          is_repost: repost.present?,
          reposted_at: repost&.created_at
        )
  end

  def format_user_favorites(user)
    user.favorites
        .includes(post: [:user, :comments, :favorites, :reposts, { images_attachments: :blob }])
        .order(created_at: :desc)
        .map do |favorite|
          favorite.post.as_json(current_user: current_api_v1_user)
        end
  end
end
