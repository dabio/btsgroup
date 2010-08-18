require 'rubygems'
require 'sinatra'
require 'haml'


Dir.glob('lib/*.rb') do |lib|
  require lib
end


configure do
  BTS = OpenStruct.new(
    :title => 'btsgroup - "Kann mir jemand bitte das Wasser reichen?"',
    :messages_per_page => 20,
    :cookie_key => "bts_user"
  )

  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:.db')

  set :haml, {:format => :html5, :ugly => true}

  enable :sessions
end


helpers do
  def paginator(path)
    haml :pagination, :layout => false, :locals => {:path => path} if @count > 1
  end

  def current_page
    @page = params[:page] and params[:page].match(/\d+/) ? params[:page].to_i : 1
  end

  def current_person
    Person.first(:id => session[:person_id])
  end

  def logged_in_as(person)
    session[:person_id] = person.id
  end

  def needs_login
    unless logged_in?
      session[:redirect] = request.fullpath
      redirect '/login'
    end
  end

  def logged_in?
    !session[:person_id].nil?
  end
end

layout 'layout'


### Public

get '/'  do
  needs_login
  @messages = Message.display_messages params[:page].to_i
  haml :index
end

get '/login' do
  haml :login
end

post '/login' do
  @person = Person.authenticate(params[:email], params[:password])
  unless @person.nil?
    logged_in_as @person
    redirect session[:redirect] ? session[:redirect] : '/'
  end
  redirect '/login'
end

get '/logout' do
  session.clear
  redirect '/login'
end

get '/settings' do
  needs_login
  @person = current_person
  haml :settings
end

post '/settings' do
  needs_login
  @person = current_person

  attributes = {}
  attributes[:email] = params['email'] unless params['email'].empty?
  attributes[:password] = params['password'] unless params['password'].empty?
  attributes[:password_confirmation] = params['password_confirmation'] unless params['password_confirmation'].empty?

  if @person.update(attributes)
    redirect '/'
  end

  haml :settings
end

#get '/setup' do
#  require 'dm-migrations'
#  DataMapper.auto_migrate!
#end
