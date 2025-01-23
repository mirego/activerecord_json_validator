# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# For default test setup with postgresql
# NOTE: If you want to run tests against MySQL do:
#   docker compose --file docker-compose.mysql.yml up -d
#   BUNDLE_GEMFILE=gemfiles/mysql.gemfile bundle install
#   BUNDLE_GEMFILE=gemfiles/mysql.gemfile DB_ADAPTER=mysql bundle exec rake spec
#   docker compose down
gem 'pg'
