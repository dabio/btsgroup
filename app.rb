#
#   this is btsgroup.de, a cuba application
#   it is copyright (c) 2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

require 'cuba'
require 'rack/no-www'

require './lib/message'


Dir.glob('./lib/*.rb') do |lib|
#  require lib
end

Cuba.use Rack::NoWWW

DataMapper.setup :default, ENV['DATABASE_URL'] || 'sqlite3:local.db'
DataMapper::Logger.new($stdout, :debug) unless ENV['RACK_END'] == 'production'

module Kernel
  private
    def coat(file)
      require 'digest/md5'
      Digest::MD5.file("public/#{file}").hexdigest[0..4]
    end
end

Cuba.define do
  def not_found()
    res.status = 404
    res.write render('views/404.haml')
  end

  on get do
    on path('') do
      @messages = Message.all(:order => [:created_at.desc], :limit => 20)
      res.write render('views/messages.haml')
    end

    on path('css/styles.css') do
      if req.query_string =~ /^\w{5}$/
        res.headers['Cache-Control'] = 'public, max-age=29030400'
      end
      res.headers['Content-Type'] = 'text/css; charset=utf-8'
      res.write render('public/css/styles.sass')
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
