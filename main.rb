# coding:utf-8

%w(sinatra haml sinatra/flash).each {|gem| require gem}

Dir.glob('./lib/*.rb') do |lib|
  require lib
end


configure do
  use Rack::Session::Cookie, :expire_after => 60 * 60 * 24 * 7

  set :title, 'btsgroup - "Kann mir jemand bitte das Wasser reichen?"'
  set :domain, 'cloud.btsgroup.de'
  set :haml, {:format => :html5, :ugly => true}

  #enable :sessions
end


before do
  # redirect to domain in settings
  if ENV['RACK_ENV'] == 'production' and request.host != settings.domain
    redirect "http://#{settings.domain}#{request.path_info}"
  end

  require_login unless ['/login', '/setup'].include?(request.path_info)
end

after do
  log_visit unless ['/login', '/logout', '/setup'].include?(request.path_info)
end


layout 'layout'

### Public

get '/'  do
  @count, @messages = Message.paginated(:page => current_page,
    :per_page => 20, :order => [:created_at.desc])

  @visits = Visit.all(:order => [:updated_at.desc])

  haml :index
end

post '/' do
  @message = Message.new(params)
  @message.person = current_person
  if @message.save
    flash[:notice] = 'Nachricht gesichert'
  end

  redirect '/'
end

get '/login' do
  if logged_in?
    redirect '/'
  end
  haml :login, :layout => false
end

post '/login' do
  @person = Person.authenticate(params[:email], params[:password])
  unless @person.nil?
    logged_in_as @person
    redirect session[:redirect] ? session[:redirect] : '/'
  end
  flash[:error] = 'Unbekannte E-Mail oder falsches Passwort eingegeben.'
  redirect '/login'
end

get '/logout' do
  session.clear
  flash[:notice] = 'Erfolgreich abgemeldet'
  redirect '/login'
end

post '/settings' do
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

error do
  Exceptional.handle_sinatra(
    request.env['sinatra_error'], request.env['REQUEST_URI'], request, params)
end

#error do redirect '/' end

#get '/setup' do
#  require 'dm-migrations'
#  DataMapper.auto_migrate!
#end
