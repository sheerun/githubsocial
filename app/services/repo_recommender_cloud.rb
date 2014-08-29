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

  def recommend(subject, options = {})
    related = []

    Librato.timing "recommend" do
      related = recommender_by_id(subject.id).recommend(subject.id, options)
    end

    {
      subject: subject.as_json(extended: true),
      results: related
    }
  end

  def logger
    Rails.logger
  end
end
