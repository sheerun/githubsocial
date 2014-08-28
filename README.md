# ![favicon](http://githubsocial.com/favicon_github.png) GithubSocial [![Code Climate][codeclimate-img-url]][codeclimate-url] [![Build Status][travis-img-url]][travis-url]

[codeclimate-img-url]: https://codeclimate.com/github/sheerun/githubsocial/badges/gpa.svg
[codeclimate-url]: https://codeclimate.com/github/sheerun/githubsocial
[travis-img-url]: https://travis-ci.org/sheerun/githubsocial.svg
[travis-url]: https://travis-ci-org/sheerun/githubsocial

Real-time collaborative repository recommendations based on GitHub stars.

## What?

Application is using information about starred repositories on GitHub, to produce clever and quick recommendation of what to like next. It recognizes collective trends by analysing hundreds of thousands of stars per recommendation.

Application is using offline data updated in real-time from [GitHub API](https://developer.github.com/v3/). Seed data has been extracted from [Github Archive](http://www.githubarchive.org/), and [GH Torrent](http://ghtorrent.org/) websites. Specifically:

- List of GitHub Repositories (stored in Postgres)
- List of GitHub Users (stored in Postgres)
- List of starred Repositories of each User (stored in Redis)

## Used algorithm

Application is using Memory-based, Item-based [Collaborative Filtering](https://en.wikipedia.org/wiki/Collaborative_filtering) algorithm using optimized [Sørensen–Dice coefficient](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient) for detecting similarity between any two repositories.

The algorithm is inspired by [predictor](https://github.com/Pathgather/predictor), with few important differences, among others:

- Similarities are computed collectively using [zunionstore](https://github.com/sheerun/githubsocial/blob/071be96a96da005a3c4b548c52cc03f81524f777/app/services/redis_recommender.rb#L13) redis command, instead of computing intersection between given repository and all repositories related to it.
- Similarities are computed and cached using [Lua Script](https://github.com/sheerun/githubsocial/blob/071be96a96da005a3c4b548c52cc03f81524f777/app/services/redis_recommender.rb#L2) executed directly in Redis instance.
- Performing computations on sets of integers instead set of strings, gaining on [Redis optimizations](http://redis.io/topics/memory-optimization). Redis is used in 32bit mode and with increased shared integer pool to improve memory usage.
- For repositories with thousand stars, a representative sample of 100-5000 users is taken for computing live recommendations in <0.1s. Full recommendations are computed in background worker to improve users' experience.

Such changes:

- allow for real-time recommendations, even with constantly refreshing database data
- reduce memory footprint needed to 850 MB per redis instance (only one is needed)

## Want to know more?

Ping me on [twitter](http://twitter.com/sheerun), or read the source.

## Requirements

- Ruby 2.1.0
- PostgreSQL 9.x
- Redis 3.0.0, preferably 32bit

## Technologies

- Ruby & Rails 4
- CoffeeScript & Angular 1.2
- [Rails Assets](https://rails-assets.org/)
- SCSS, SLIM
- Sidekiq

## Installation

Application requires Redis and PostgreSQL database dumps. They can be downloaded using `bin/download` script. Please download only if you really need to test live data.

```bash
bin/download
# db/dump.rdb (Redis)
# db/dump.sql.gz (PostgreSQL)
```

You'll also need compiled redis instance in 32bit mode, and increased shared integer count (memory savings):

```diff
-#define REDIS_SHARED_INTEGERS 10000
+#define REDIS_SHARED_INTEGERS 15000000
```

```bash
make 32bit
```

After your redis instance is up and running with downloaded `dump.rdb`, and PostgreSQL with imported `dump.sql.gz`, you can bundle application:

```ruby
bundle install
bin/rake db:create
bin/rake db:migrate
```

You also need to create github application with callback set to:

```
http://localhost:3000/auth/github/callback
```

And add `.env` file with following configuration:

```
GITHUB_KEY=xxx
GITHUB_SECRET=yyy
```

Application and sidekiq worker can be started with:

```bash
bin/foreman start
```

## Contributing

We need help with following:

1. Making recommendation engine even more performant
2. Better front-end design and interaction (author is Ruby developer)
3. Improvements in recommendation algorithm to get better suggestions
4. Testing, fixing and maintaining application.

If you think you could help, please post issue or pull request on this repository.

## License

This project is [MIT-licensed](http://opensource.org/licenses/mit-license.php).
