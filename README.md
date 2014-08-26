# ![favicon](http://githubsocial.com/favicon_github.png) GithubSocial [![Dependency Status][gemnasium-img-url]][gemnasium-url] [![Code Climate][codeclimate-img-url]][codeclimate-url] [![Build Status][travis-img-url]][travis-url]

[codeclimate-img-url]: https://codeclimate.com/github/sheerun/githubsocial/badges/gpa.svg
[codeclimate-url]: https://codeclimate.com/github/sheerun/githubsocial
[gemnasium-img-url]: https://gemnasium.com/sheerun/githubsocial.png
[gemnasium-url]: https://gemnasium.com/sheerun/githubsocial
[travis-img-url]: https://travis-ci.org/sheerun/githubsocial.svg
[travis-url]: https://travis-ci-org/sheerun/githubsocial

Collaborative repository recommendations based on GitHub stars.

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
