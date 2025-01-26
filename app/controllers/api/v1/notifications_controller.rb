# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        notifications = current_api_v1_user.notifications
                                         .recent
                                         .includes(notifiable: [:user, :post])
        render json: notifications.map { |notification| format_notification(notification) }
      end

      private

      def format_notification(notification)
        {
          id: notification.id,
          action: notification.action,
          created_at: notification.created_at,
          notifiable: format_notifiable(notification.notifiable, notification.action),
          actor: format_actor(notification.notifiable)
        }
      end

      def format_notifiable(notifiable, action)
        return nil if notifiable.nil?

        case action
        when 'like', 'repost'
          format_post(notifiable.post)
        when 'comment'
          format_comment(notifiable)
        when 'follow'
          nil
        end
      end

      def format_actor(notifiable)
        return nil if notifiable.nil?

        case notifiable
        when Favorite, Comment, Repost
          format_user(notifiable.user)
        when Relationship
          format_user(notifiable.follower)
        end
      end

      def format_post(post)
        return nil if post.nil?

        {
          id: post.id,
          content: post.content,
          created_at: post.created_at
        }
      end

      def format_comment(comment)
        {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at,
          post: format_post(comment.post),
          email: comment.user.email
        }
      end

      def format_user(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          avatar_url: user.avatar_image.attached? ? url_for(user.avatar_image) : nil
        }
      end
    end
  end
end
