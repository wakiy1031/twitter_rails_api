# frozen_string_literal: true

module UserStatsFormatter
  extend ActiveSupport::Concern

  private

  def user_stats(user)
    {
      posts_count: user.posts.count,
      followers_count: user.followers.count,
      following_count: user.following.count,
      is_following: current_api_v1_user&.following?(user)
    }
  end

  def user_content(user)
    {
      tweets: format_user_tweets(user),
      comments: format_user_comments(user),
      favorites: format_user_favorites(user)
    }
  end
end
