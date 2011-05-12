# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

# SET RACK_ENV to test
ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require './app'
require 'test/unit'
require 'rack/test'

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:db/test.db?encoding=utf8')

# create dummy user for testing authenticated views
Person.create(first_name: 'Dummy', last_name: 'User', email: 'dummy@user.com',
              password: 'test123', password_confirmation: 'test123')


class TestHelper < Test::Unit::TestCase
  include Rack::Test::Methods
  include Helpers

  def app
    BTS
  end

  def login
    post '/login', {email: 'dummy@user.com', password: 'test123'}
  end

  def logout
    get '/logout'
  end

end

