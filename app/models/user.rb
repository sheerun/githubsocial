class User < ActiveRecord::Base

  class UpdateStarredJob
    include Sidekiq::Worker

    def perform(id)
      User.find(id).update_starred!
    end
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    User.find_or_initialize_by(id: auth_hash.uid).tap do |user|
      user.login = auth_hash.info.nickname
      user.github_token = auth_hash.credentials.token
      user.save!
    end
  end

  def as_json(options = {})
    hash = {
      id: id,
      login: login,
      avatar_url: "https://avatars.githubusercontent.com/u/#{id}?v=2"
    }

    if options[:extended]
      hash[:github_token] = github_token
    end

    hash
  end

  def github
    Octokit::Client.new(access_token: github_token)
  end

  def starred_ids
    Set.new(Redis.current.smembers("starred:#{id}").map(&:to_i))
  end

  def github_starred_ids
    Octokit.auto_paginate = true
    stars = github.starred(login)
    Set.new(stars.map(&:id))
  end

  def update_starred!
    github_stars = github_starred_ids
    unstarred = github_stars - starred_ids
    surplus = starred_ids - github_stars

    unstarred.each_slice(100) do |starred_slice|
      Redis.current.sadd("starred:#{id}", starred_slice)
    end

    surplus.each_slice(100) do |surplus_size|
      Redis.current.srem("starred:#{id}", surplus_size)
    end

    unstarred.each do |id|
      Redis.current.sadd("stargazers:#{id}", id)
    end

    surplus.each do |id|
      Redis.current.srem("starred:#{id}", id)
    end

    unstarred.size - surplus.size
  end
end
