class RepoRecommenderCloud
  include Singleton
  include ActiveSupport::Benchmarkable

  def initialize(master = Redis.new(:driver => :hiredis), slaves = nil)
    @master = master
    @slaves = slaves || [master]
  end

  def recommender_by_id(repo_id)
    slave = @slaves[repo_id.to_i % @slaves.size]
    RedisRecommender.new(slave, "stargazers", "starred")
  end

  def recommend(repo_id, options = {})
    subject = Repo.find_by(id: repo_id)

    related = []

    benchmark "recommend" do
      related = recommender_by_id(repo_id).recommend(repo_id, max_sample: 100)
    end

    {
      subject: subject.as_json(extended: true),
      related: related
    }
  end

  def logger
    Rails.logger
  end
end
