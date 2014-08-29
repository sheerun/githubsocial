class RedisRecommender
  SCRIPT = """
    local call = redis.call

    local collection_prefix = ARGV[1]
    local collection_size   = tonumber(ARGV[2])
    local min_connectivity  = tonumber(ARGV[3])
    local max_matches       = tonumber(ARGV[4])
    local penalize_factor   = ARGV[5]
    local related_cache     = ARGV[6]

    call('del', 'tmp')

    -- collect counts of stars on repos by users
    for i=1,#KEYS,5000 do
      call(
        'zunionstore', 'tmp',
        math.min(5000, #KEYS),
        unpack(KEYS, i, math.min(i + 4999, #KEYS))
      )
    end

    local items = call(
      'zrevrangebyscore', 'tmp', '+inf', min_connectivity, 'withscores'
    )

    redis.log(redis.LOG_NOTICE, '')
    redis.log(redis.LOG_NOTICE, #KEYS)
    redis.log(redis.LOG_NOTICE, #items)
    redis.call('del', 'tmp')

    if #items > 0 then
      local min_similarity = 0.05

      local threshold = items[2] /
        ((penalize_factor + 1) * collection_size) * min_similarity

      -- penalize with Soensen–Dice coefficient
      local new_items = {}
      local j = 1
      local prefix = collection_prefix .. ':'
      for i=1,#items,2 do
        local new_score = items[i + 1] / (
          penalize_factor * call('scard', prefix .. items[i]) + collection_size
        )
        if new_score > threshold then
          new_items[j] = new_score
          new_items[j + 1] = items[i]
          j = j + 2
        end
      end

      for i=1,#new_items,5000 do
        call(
          'zadd', 'tmp', unpack(new_items, i, math.min(i + 4999, #new_items))
        )
      end

      local result = call('zrevrange', 'tmp', 0, max_matches, 'withscores')

      call('del', 'tmp')

      return result
    else
      return {}
    end

  """

  attr_accessor :redis
  attr_accessor :item_prefix
  attr_accessor :user_prefix

  def initialize(redis, item_prefix, user_prefix)
    @redis = redis
    @command = @redis.script(:load, SCRIPT)
    @item_prefix = item_prefix
    @user_prefix = user_prefix
  end

  def cached_ratings(id, options = {})
    cache_key = "related:#{@item_prefix}:#{id}"

    if @redis.exists(cache_key) && !options[:force]
      @redis.zrevrange(cache_key, 0, -1, withscores: true)
    else
      size = @redis.scard("#{@item_prefix}:#{id}")

      min_connectivity = [
        2,
        options.fetch(:min_connectivity, (Math.sqrt(size) / 10).ceil)
      ].max

      max_sample = options.fetch(:max_sample, 500)

      ids = @redis.sdiff("#{@item_prefix}:#{id}", "overgazers")

      sets = ids.sample(max_sample).map { |id|
        "#{@user_prefix}:#{id}"
      }

      penalize_factor = options.fetch(:penalize_factor, 3)

      @redis.evalsha(
        @command,
        sets,
        [@item_prefix, size, min_connectivity, 30, penalize_factor, cache_key]
      ).each_slice(2).to_a
    end
  end

  def recommend(id, options = {})
    id = id.to_i

    raw_ratings = cached_ratings(id, options)

    return [] if raw_ratings.empty?

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

      next [] if id == key
      next [] if to_skip.include?(key)

      [repos_hash[key].merge(
        similarity: (val.to_f / max_score * 100).round
      )]
    end
  end
end
