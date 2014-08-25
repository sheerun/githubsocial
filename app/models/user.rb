class User < ActiveRecord::Base

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
end
