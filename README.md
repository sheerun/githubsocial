# ![favicon](http://githubsocial.com/favicon-24.png) Github Social 

[codeclimate-img-url]: https://codeclimate.com/github/sheerun/githubsocial/badges/gpa.svg
[codeclimate-url]: https://codeclimate.com/github/sheerun/githubsocial
[travis-img-url]: https://travis-ci.org/sheerun/githubsocial.svg
[travis-url]: https://travis-ci.org/sheerun/githubsocial

Real-time collaborative repository recommendations based on GitHub stars.

## About

Application shows related GitHub projects, by analysing GitHub stars.

Application is using offline data that is updated continously from [GitHub API](https://developer.github.com/v3/). The seed database has been extracted from [Github Archive](http://www.githubarchive.org/), and [GH Torrent](http://ghtorrent.org/) websites. Specifically:

* List of GitHub Repositories and Users (stored in PostgreSQL)
* List of starred Repositories of each User (stored in Redis)

## Used algorithm

Application is using Memory-based, Item-based [Collaborative Filtering](https://en.wikipedia.org/wiki/Collaborative_filtering) algorithm using modifier [Sørensen–Dice coefficient](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient) for detecting similarity between given two repositories.

We use similar approach to [predictor](https://github.com/Pathgather/predictor), with important differences, among others:

- Instead of computing intersection of stars between given repository and all repositories related to it, similarities are computed massively using [zunionstore](https://github.com/sheerun/githubsocial/blob/master/app/services/redis_recommender.rb#L13) Redis command.
- Similarities are computed and cached using Lua script executed directly in Redis instance.
- For repositories with thousand stars, a representative sample of 100-5000 users is taken.
- Employ [optimizations](http://redis.io/topics/memory-optimization) by  computations on sets of integers instead set of strings.
- Redis is used in 32bit mode and with increased shared integer pool to improve memory usage.
- The "popularity penalty factor" is used for discovering less popular repositories. The penalty factor can be provided by user.

## Performance

Algorithm is able to analyse hundreds of thousands of stars under 0.5s while maintaining memory usage less than 1GB on GitHub dataset.

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

```
#define REDIS_SHARED_INTEGERS 15000000
```

```
make 32bit
```

After your redis instance is up and running with downloaded `dump.rdb`, and PostgreSQL with imported `dump.sql.gz`, you can bundle application:

```
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
