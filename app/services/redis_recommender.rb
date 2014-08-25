class RedisRecommender
  SCRIPT = """
    redis.log(redis.LOG_NOTICE, '')

    redis.log(redis.LOG_NOTICE, #KEYS)

    local collection_prefix = ARGV[1]
    local collection_size   = tonumber(ARGV[2])
    local min_connectivity  = tonumber(ARGV[3])
    local max_matches       = tonumber(ARGV[5])

    redis.log(redis.LOG_NOTICE, min_connectivity)

    -- collect counts of stars on repos by users
    redis.call('del', 'tmp')
    redis.call('zunionstore', 'tmp', #KEYS, unpack(KEYS))
    redis.call('zremrangebyscore', 'tmp', '-inf', min_connectivity - 1)
    local items = redis.call('zrevrange', 'tmp', 0, -1, 'withscores')
    redis.log(redis.LOG_NOTICE, redis.call('zcard', 'tmp'))
    redis.call('del', 'tmp')

    local min_similarity = 0.1
    local threshold = items[2] / (2 * collection_size) * min_similarity

    -- penalize with Soensen–Dice coefficient
    local new_items = {}
    local min_score = 1000000
    local j = 1
    for i=1,#items,2 do
      local card = redis.call('scard', collection_prefix .. ':' .. items[i])
      local new_score = items[i + 1] / (card + collection_size)
      if new_score > threshold then
        new_items[j] = new_score
        new_items[j + 1] = items[i]
        j = j + 2
      end
    end

    redis.log(redis.LOG_NOTICE, j)

    for i=1,#new_items,5000 do
      redis.call('zadd', 'tmp', unpack(new_items, i, math.min(i + 4999, #new_items)))
    end

    redis.log(redis.LOG_NOTICE, redis.call('zcard', 'tmp'))

    local result = redis.call('zrevrange', 'tmp', 0, max_matches, 'withscores')

    redis.call('del', 'tmp')

    return result
  """

  attr_accessor :redis
  attr_accessor :collection_prefix
  attr_accessor :contracollection_prefix

  def initialize(redis, collection_prefix, contracollection_prefix)
    @redis = redis
    @command = @redis.script(:load, SCRIPT)
    @collection_prefix = collection_prefix
    @contracollection_prefix = contracollection_prefix
  end

  def recommend(collection_id, options = {})
    collection_id = collection_id.to_i

    size = @redis.scard("#{@collection_prefix}:#{collection_id}")
    min_connectivity = [2, options.fetch(:min_connectivity, (Math.sqrt(size) / 10).ceil)].max

    max_sample = options.fetch(:max_sample, 250)
    sets = @redis.srandmember("#{@collection_prefix}:#{collection_id}", max_sample).
      map { |contracollection_id| "#{@contracollection_prefix}:#{contracollection_id}" }

    raw_ratings = @redis.evalsha(
      @command,
      sets,
      [@collection_prefix, size, min_connectivity, 5, 25]
    )

    max_score = raw_ratings[1].to_f

    repo_ids = raw_ratings.each_slice(2).map { |key, val| key.to_i }
    repos = Repo.where(id: repo_ids).to_a
    owners_logins = repos.map { |r| r.owner }
    owners = User.where(login: owners_logins).to_a.index_by(&:login)

    repos_hash = {}
    repos.each do |repo|
      repos_hash[repo.id] = repo.as_json.merge(
        :owner => owners[repo['owner']].as_json ||  {
          id: 0,
          login: 'unknown',
          avatar_url: 'https://avatars.githubusercontent.com/u/0?v=2'
        }.as_json
      )
    end

    to_skip = []

    if options[:user_id]
      to_skip = Set.new(
        @redis.smembers("starred:#{options[:user_id]}").map!(&:to_i)
      )
    end

    raw_ratings.each_slice(2).flat_map do |key, val|
      key = key.to_i

      next [] if collection_id == key
      next [] if to_skip.include?(key)

      [repos_hash[key].merge(
        similarity: (val.to_f / max_score * 100).round
      )]
    end
  end
end
