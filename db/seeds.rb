# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.destroy_all

users = []

10.times do |u|
  user = User.find_or_initialize_by(
    name: "test_user_#{u + 1}",
    email: "test_user-#{u + 1}@example.com",
    phone: "090111122#{u.to_s.rjust(2, '0')}"
  )
  user.birthdate = '2024-07-03'
  user.password = 'password'
  user.password_confirmation = 'password'
  user.skip_confirmation!
  user.save!

  users << user

  15.times do |t|
    post = user.posts.build(
      content: "テストユーザー#{u + 1}の#{t + 1}個目のツイート"
    )
    post.save!
  end
end
