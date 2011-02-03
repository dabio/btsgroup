#
#   this is btsgroup.de, a cuba application
#   it is copyright (c) 2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

require 'cuba'
require 'slim'
require 'rack/no-www'

Dir.glob('./lib/*.rb') do |lib|
  require lib
end

Cuba.use Rack::NoWWW

Cuba.define do
  extend Cuba::Prelude

  on get do
    on path('') do
      @messages = {}
      res.write slim 'messages'
    end

    on path('login') do
      @auth ||= Rack::Auth::Basic::Request.new(env)

      if @auth.provided? and @auth.basic? and @auth.credentials
        @person = authenticate(@auth.credentials[0], @auth.credentials[1])
      end

      unless @person
        res.headers['WWW-Authenticate'] = %(Basic realm='btsgroup')
        res.status = 401
        res.write 'Don\'t think we don\'t love you.'
      else
        # set session
        res.redirect '/'
      end
    end

    on path('css'), path('styles.css') do
      res.write stylesheet('css/styles.sass')
    end

    on default do
      not_found
    end
  end

  on post do
    path('settings') do
      # save settings
    end
  end
end

