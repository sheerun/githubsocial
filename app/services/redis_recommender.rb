class RedisRecommender
  SCRIPT = """
    local collection_prefix = ARGV[1]
    local collection_size   = tonumber(ARGV[2])
    local min_connectivity  = tonumber(ARGV[3])
    local max_matches       = tonumber(ARGV[4])
    local related_cache     = ARGV[5]

    -- collect counts of stars on repos by users
    redis.call('del', 'tmp')

    for i=1,#KEYS,5000 do
      redis.call('zunionstore', 'tmp', math.min(i + 4999, #KEYS) - i + 1, unpack(KEYS, i, math.min(i + 4999, #KEYS)))
    end

    redis.call('zremrangebyscore', 'tmp', '-inf', min_connectivity - 1)
    local items = redis.call('zrevrange', 'tmp', 0, -1, 'withscores')
    redis.call('del', 'tmp')

    local min_similarity = 0.05
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

    redis.call('del', related_cache)

    for i=1,#new_items,5000 do
      redis.call('zadd', related_cache, unpack(new_items, i, math.min(i + 4999, #new_items)))
    end

    redis.call('zremrangebyrank', related_cache, 0, -max_matches)

    redis.call('del', 'tmp') -- in case related_cache is tmp

    return redis.call('zrevrange', related_cache, 0, -1, 'withscores')
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

  def cached_ratings(collection_id, options = {})
    cache_key = "related:#{@collection_prefix}:#{collection_id}"

    if @redis.exists(cache_key) && !options[:force]
      @redis.zrevrange(cache_key, 0, -1, withscores: true)
    else
      size = @redis.scard("#{@collection_prefix}:#{collection_id}")
      min_connectivity = [2, options.fetch(:min_connectivity, (Math.sqrt(size) / 10).ceil)].max

      max_sample = options.fetch(:max_sample, 200)
      sets = @redis.srandmember("#{@collection_prefix}:#{collection_id}", max_sample).
        map { |contracollection_id| "#{@contracollection_prefix}:#{contracollection_id}" }

      @redis.evalsha(
        @command,
        sets,
        [@collection_prefix, size, min_connectivity, 25, cache_key]
      ).each_slice(2).to_a
    end
  end

  def recommend(collection_id, options = {})
    collection_id = collection_id.to_i

    raw_ratings = cached_ratings(collection_id, options)

    max_score = raw_ratings[0][1].to_f

    repo_ids = raw_ratings.map { |key, val| key.to_i }
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

    raw_ratings.flat_map do |key, val|
      key = key.to_i

      next [] if collection_id == key
      next [] if to_skip.include?(key)

      [repos_hash[key].merge(
        similarity: (val.to_f / max_score * 100).round
      )]
    end
  end
end
