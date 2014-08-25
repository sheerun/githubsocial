require 'oj'
require 'redis'
require 'pg'
require 'upsert'


namespace :import do
  desc "Import watchers from ghtorrent export"
  task :watchers => [:environment] do
    recommender = RepoRecommender.new

    $stdin.each_line do |line|
      login_id, repo_id = line.split(' ')
      recommender.add_to_matrix(:users, login_id, repo_id)
    end
  end

  task :repos => [:environment] do
    STDIN.each_line.each_slice(500) do |lines|
      Upsert.batch(Repo.connection, Repo.table_name) do |upsert|

        mapped = lines.map do |line|
          data = Oj.load(line)
          owner, name = data['full_name'].split('/')

          mapped = {
            name: name,
            owner: owner,
            description: data['description'] || '',
            homepage: data['homepage'] || '',
            parent_id: data['parent_id'] ? data['parent_id'].to_i : nil,
            source_id: data['source_id'] ? data['parent_id'].to_i : nil,
            language: data['language'] || '',
            pushed_at: data['pushed_at'],
            stargazers_count: data.fetch('stargazers_count', data['watchers']).to_i,
            watchers_count: data.fetch('watchers_count', data['watchers']).to_i,
            open_issues: data['open_issues'].to_i,
            created_at: data['created_at'],
            updated_at: data['updated_at']
          }

          upsert.row({:id => data['id'].to_i}, mapped)
        end
      end
    end
  end

  task :users => [:environment] do
    STDIN.each_line.each_slice(100) do |lines|
      Upsert.batch(User.connection, User.table_name) do |upsert|
        lines.map do |line|
          data = Oj.load(line)

          mapped = {
            login: data['login'],
            site_admin: data['site_admin'],
            gravatar_id: data['gravatar_id']
          }
          
          upsert.row({ :id => data["id"].to_i }, mapped)
        end
      end
    end
  end

  task :keys => [:environment] do
    redis = Redis.new

    $stdin.each_line.each_slice(1000) do |lines|

      datas = lines.map { |line| Oj.load(line) }
      users = datas.map { |data| data["login"] }
      repos = datas.map { |data| "#{data["owner"]}/#{data["repo"]}" }

      users_ids = redis.mget(*users)
      repos_keys = redis.mget(*repos)

      to_put = ""

      users_ids.zip(repos_keys).each do |user_id, repo_id|
        to_put << "#{user_id} #{repo_id}\n" if user_id && repo_id
      end

      STDOUT.write to_put
    end
  end
end
