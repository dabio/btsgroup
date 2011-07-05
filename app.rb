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
  set :method_override, true
  set :root, root_path
  set :default_locale, 'de'
  set :cdn, '//btsgroup.commondatastorage.googleapis.com'

  register Sinatra::R18n

  use Rack::ForceDomain, ENV['DOMAIN']
  use Rack::Session::Cookie, expire_after: 60 * 60 * 24 * 7
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
    redirect to('/login') unless has_auth?

    @events = EventLink.all(:time.gte => today, :time.lt => today >> 1, order: [:time])
    @visits = Visit.all(order: [:updated_at.desc])
    @count, @messages = Message.paginated(page: current_page, per_page: 20,
                                          order: [:created_at.desc])
    slim :index
  end


  post '/new' do
    redirect to('/login') unless has_auth?

    message = Message.new(params[:message])
    message.person = current_person

    status 500 unless message.save
  end


  get '/login' do
    redirect to('/') if has_auth?
    slim :login
  end


  post '/login' do
    @person = Person.authenticate(params[:email], params[:password])

    if @person
      session[:person_id] = @person.id
      redirect to('/')
    end

    flash[:notice] = 'Unbekannte E-Mail oder falsches Passwort eingegeben.'
    slim :login
  end


  get '/logout' do
    session[:person_id] = nil if has_auth?
    redirect to('/login')
  end


  get '/settings' do
    redirect to('/login') unless has_auth?
    slim :settings
  end


  put '/settings' do
    redirect to('login') unless has_auth?

    current_person.attributes = {
      email: params[:person]['email'],
      notice: params[:person]['notice']
    }

    unless params[:person]['password'].nil? or params[:person]['password'].empty?
      current_person.password = params[:person]['password']
      current_person.password_confirmation = params[:person]['password_confirmation']
    end

    status 500 unless current_person.save
  end


  post '/update.json' do
    redirect to('/login') unless has_auth?

    now = Time.now
    Visit.first_or_create(person: current_person).update(created_at: now)

    # get last visit
    last_visit = params[:last_visit] ? params[:last_visit] : now.to_i
    callback_functions = ['save_last_visit']

    # get new messages
    messages = Message.all(:updated_at.gte => Time.at(last_visit.to_i),
                           :order => :updated_at.desc)
    messages_html = []
    messages.each do |message|
      messages_html << slim(:_message, locals: {message: message})
    end
    callback_functions.push('show_messages') if messages.length > 0

    content_type :json
    {'last_visit' => now.to_i, 'callback' => callback_functions,
         'messages' => messages_html}.to_json
  end

end

# helpers
require(root_path('helpers.rb'))

# models
Dir[root_path('models/*.rb')].each { |file| require file }

