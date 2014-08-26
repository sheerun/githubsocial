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

## Installation

Application requires Redis and PostgreSQL database dumps. They can be downloaded using `bin/download` script.

```ruby
bin/download
# db/dump.rdb (Redis)
# db/dump.sql.gz (PostgreSQL)
```

## License

This project is [MIT-licensed](http://opensource.org/licenses/mit-license.php).
