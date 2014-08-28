class Repo < ActiveRecord::Base

  # Perform very accurate recommendation in background
  # To achieve it use user sample of 5000 instead usual 100
  class CacheRelatedJob
    include Sidekiq::Worker
    include Sidekiq::Benchmark::Worker

    sidekiq_options :retry => false

    def perform(id)
      benchmark do |bm|
        repo = Repo.find(id)

        raise "Unknown repository" unless repo

        bm.recommend do
          RepoRecommenderCloud.instance.cached_ratings(repo, max_sample: 5000, force: true)
        end
      end
    end
  end

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
