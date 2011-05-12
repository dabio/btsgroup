# encoding: utf-8
#
#   this is pinub.com, a sinatra application
#   it is copyright (c) 2010-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

require 'bundler'
Bundler.require

RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined? RACK_ENV
ROOT_DIR = File.dirname(__FILE__) unless defined? ROOT_DIR

# Helper method for file references.
#
# @params args [Array] Path components relative to ROOT_DIR.
# @example Referencing a file in config called settings.yml:
#   root_path('config', 'settings.xml')
def root_path(*args)
  File.join(ROOT_DIR, *args)
end


# Sinatra::Base. This way, we're not polluting the global namespace with your
# methods and routes and such.
class BTS < Sinatra::Base; end

class BTS
  set :root, root_path
  set :default_locale, 'de'

  register Sinatra::R18n

  use Rack::ForceDomain, ENV['DOMAIN']
  # We're using rack-timeout to ensure that our dynos don't get starved by
  # renegade processes.
  use Rack::Timeout
  Rack::Timeout.timeout = 10

  configure :development, :test do
    begin
      require 'ruby-debug'
    rescue LoadError
    end
  end

  helpers do
    [:development, :production, :test].each do |environment|
      define_method "#{environment.to_s}?" do
        return settings.environment == environment.to_sym
      end
    end
  end

  DataMapper::Logger.new($stdout, :debug) if development?
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:db/local.db?encoding=utf8')


  # for wasitup
  head '/' do; end


  get '/' do
    redirect(to('/login')) unless has_auth?

    @count, @messages = Message.paginated
  end


  post '/new' do
  end


  get '/login' do
  end


  post '/login' do
  end


  get '/logout' do
  end


  put '/settings' do
  end

end

# helpers
require(root_path('helpers.rb'))

# models
Dir[root_path('models/*.rb')].each { |file| require file }

