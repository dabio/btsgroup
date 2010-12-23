#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

require 'sinatra'
require 'sinatra/flash'
require 'sinatra/r18n'
require 'haml'
require 'hassle'


Dir.glob('./lib/*.rb') do |lib|
  require lib
end


use Rack::Session::Cookie, :expire_after => 60 * 60 * 24 * 7

configure do
  DataMapper::Logger.new($stdout, :debug) unless production?
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:local.db')

  set :title, 'Frohes Fest!'
  set :domain, 'btsgroup.de'
  set :haml, {:format => :html5}
  set :default_locale, 'de'
end


before do
  # redirect to domain in settings
  if !development? and request.host != settings.domain
    redirect "http://#{settings.domain}#{request.path_info}"
  end
end

after do
  Visit.first_or_create(:person => current_person).update(:updated_at => Time.now) if has_auth?
end


not_found do
  redirect '/login'
end


# login & logout

get '/login' do
  redirect '/' if has_auth?
  haml :login, :layout => false
end

post '/login' do
  @person = authenticate(params[:email], params[:password])

  unless @person
    flash[:error] = 'Unbekannte E-Mail oder falsches Passwort eingegeben.'
    redirect '/login'
  end

  session[:person_id] = @person.id
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/login'
end


# messages

get '/'  do
  needs_auth
  t = Date.today

  @count, @messages = Message.paginated(:page => current_page,
    :per_page => 20, :order => [:created_at.desc])

  @visits = Visit.all(:order => [:updated_at.desc])
  @events = EventLink.all(:time.gte => t, :time.lt => t >> 1, :order => [:time])

  haml :index
end


post '/new' do
  needs_auth

  @message = Message.new(params)
  @message.person = current_person

  if @message.save
    flash[:notice] = 'Nachricht gesichert'
    redirect '/'
  else
    haml :index
  end
end


post '/settings' do
  needs_auth

  @person = current_person

  attributes = {}
  attributes[:email] = params['email'] unless params['email'].empty?
  attributes[:password] = params['password'] unless params['password'].empty?
  attributes[:password_confirmation] = params['password_confirmation'] unless params['password_confirmation'].empty?

  if @person.update(attributes)
    flash[:notice] = 'Einstellungen gespeichert'
  end

  redirect '/'
end

