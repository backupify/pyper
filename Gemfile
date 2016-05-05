source 'https://rubygems.org'

# Specify your gem's dependencies in storage_pipeline.gemspec
gemspec

group :development, :test do
  gem "pry"
  gem "awesome_print"
  gem 'm', :git => 'git@github.com:ANorwell/m.git', :branch => 'minitest_5'
  gem 'cass_schema', :git => 'git@github.com:backupify/cass_schema.git', :tag => "0.0.4"

  # make sure to use v2.0.1 to avoid issues with super column families
  gem 'cassandra-driver', :git => 'git@github.com:datastax/ruby-driver.git', :tag => 'v2.0.1'
end

group :test do
  gem 'minitest_should', :git => 'git@github.com:citrus/minitest_should.git'
  gem "google-api-client", "0.7.1"
  gem "mocha"
  gem 'virtus'
end

gem 'storage_strategy', :git => 'git@github.com:backupify/storage_strategy.git'
gem 'cassava_rb'
