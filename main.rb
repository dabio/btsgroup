require 'rubygems'
require 'sinatra'
require 'haml'


Dir.glob('lib/*.rb') do |lib|
  require lib
end


configure do
  use Rack::Session::Cookie, :expire_after => 60 * 60 * 24 * 7

  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:.db')

  set :title, 'btsgroup - "Kann mir jemand bitte das Wasser reichen?"'
  set :per_page, 20

  set :haml, {:format => :html5, :ugly => true}

  enable :sessions
end


helpers do
  def current_page
    @page = params[:page] && params[:page].match(/\d+/) ? params[:page].to_i : 1
  end

  def current_person
    Person.first(:id => session[:person_id])
  end

  def log_visit
    visit = Visit.first_or_create(:person => current_person)
    visit.updated_at = Time.now
    visit.save
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

  def paginator(path)
    haml :pagination, :escape_html => false, :layout => false,
      :locals => {:path => path} if @count > 1
  end

  def pluralize(singular, plural, amount)
      amount > 1 ? plural : singular
  end

  def timesince(d, now=Time.now)
    delta = (now - d).to_i
    return '0 Minuten' if delta <= 60

    chunks = [
      [60 * 60 * 24 * 356,  lambda {|n| pluralize('Jahr', 'Jahre', n)}],
      [60 * 60 * 24 * 30,   lambda {|n| pluralize('Monat', 'Monate', n)}],
      [60 * 60 * 24 * 7,    lambda {|n| pluralize('Woche', 'Wochen', n)}],
      [60 * 60 * 24,        lambda {|n| pluralize('Tag', 'Tage', n)}],
      [60 * 60,             lambda {|n| pluralize('Stunde', 'Stunden', n)}],
      [60,                  lambda {|n| pluralize('Minute', 'Minuten', n)}]
    ]

    ret = ''
    i = 0

    chunks.each do |seconds, name|
      amount, delta = delta.divmod(seconds)
      if amount > 0
        ret << "#{amount} #{name[amount]} "
        i += 1
      end
      break if i > 1
    end
    ret.strip
  end
end


before do
  needs_login unless request.path_info == '/login'
end

after do
  log_visit unless ['/login', '/logout'].include?(request.path_info)
end


layout 'layout'

### Public

get '/'  do
  #current_page().to_s
  @count, @messages = Message.paginated(:page => current_page,
    :per_page => options.per_page, :order => [:created_at.desc])
  
  @visits = Visit.all(:order => [:updated_at.desc])
  
  haml :index
end

post '/' do
  @message = Message.new(params)
  @message.person = current_person
  @message.save

  redirect '/'
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
  @person = current_person
  haml :settings
end

post '/settings' do
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
