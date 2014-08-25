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
    benchmark "recommend" do
      recommender_by_id(repo_id).recommend(repo_id, max_sample: 1000)
    end
  end

  def logger
    Rails.logger
  end
end
