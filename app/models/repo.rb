class Repo < ActiveRecord::Base

  def as_json(options = {})
    hash = {
      id: id,
      owner: owner,
      name: name,
      full_name: "#{owner}/#{name}",
      description: description,
      stargazers_count: Redis.current.scard("stargazers:#{id}"),
      html_url: "https://github.com/#{owner}/#{name}"
    }

    if options[:extended]
      user = User.find_by(login: owner).try(:as_json)

      if user
        hash[:owner] = user.as_json
      else
        hash[:owner] = {
          id: 0,
          login: 'unknown',
          avatar_url: 'https://avatars.githubusercontent.com/u/0?v=2'
        }
      end
    end

    hash
  end
end
