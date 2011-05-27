# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

task :default => :test
task :test do
  require 'fileutils'
  require 'rake/testtask'

  # copy actual database file aside for testing
  FileUtils.cp 'db/local.db', 'db/test.db'

  Rake::TestTask.new do |t|
    t.libs << 'test'
    t.pattern = 'test/test_*.rb'
    t.verbose = true
  end
end


task :uninstall do
  system "rvm", "--force", "gemset", "empty"
  File.unlink "Gemfile.lock"
end

task :install do
  system "gem", "install", "bundler"
  system "bundle", "install", "--without", "production"
end

namespace "db" do
  task :prepare do
    require './app'

    DataMapper::Logger.new $stdout, :debug
    DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:db/local.db?encoding=utf8')
  end

  desc 'Create the database tables.'
  task :migrate => :prepare do
    require 'dm-migrations'
    DataMapper.auto_migrate!
  end

  desc 'Upgrade the database tables.'
  task :upgrade => :prepare do
    adapter = DataMapper.repository(:default).adapter
    adapter.execute('ALTER TABLE people ADD COLUMN `notice` integer NOT NULL DEFAULT 2;')
  end

  desc 'Pull database from heroku'
  task :pull do
    system "heroku", "db:pull", "sqlite://db/local.db?encoding=utf8"
  end

  desc 'Push database to heroku'
  task :push do
    system "heroku", "db:push", "sqlite://db/local.db?encoding=utf8"
  end
end


