require 'camping'

Camping.goes :BTS


module BTS
  use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
  use Rack::CommonLogger
end


class << BTS
  def root
    File.dirname(__FILE__)
  end
  
  def config
    @config ||= YAML.load(IO.read(File.join(root, 'config', 'config.yml'))).symbolize_keys
  end
  
  def title
    config[:title]
  end
end


module BTS::Models
  class User < Base
    has_many :messages
  end
  
  class Message < Base
    belongs_to :user
  end
  
  class CreateTheBasics < V 1.0
    def self.up
      create_table User.table_name do |t|
        t.string    :first_name, :null => false
        t.string    :last_name, :null => false
        t.string    :email
        t.string    :password
        t.date      :birthday
        t.datetime  :last_seen
        t.timestamps
      end
      
      create_table Message.table_name do |t|
        t.text    :text, :null => false
        t.integer :user_id, :null => false
        t.timestamps
      end
    end
    
    
    def self.down
      drop_table User.table_name
      drop_table Message.table_name
    end
  end
end

module BTS::Controllers
  class Index
    def get
      if (page = @input.page.to_i) > 0
        page -= 1
      end
      # fetch messages
      @messages = Message.all :offset => page * 20, :limit => 20, :order => "created_at DESC"
      render :list
    end
  end
  
  class Login
    def get
      #@state.user_id = 1
      render :login
    end
    
    def post
      @user = User.find_by_email(input.email)
      if @user
        @state.user_id = @user.id
      end
    end
  end
  
  class Logout
    def get
      @state.user_id = nil
      redirect Login
    end
  end
end


module BTS::Views
  def layout
    xhtml_strict
    html do
      head do
        title BTS.title
        link :rel => "stylesheet", :href => "/css/style.css"
      end
      body do
        self << yield
      end
    end
  end
  
  
  def list
    ul do
      @messages.each do |message|
        li do
          div message.text
          div message.user.first_name
        end
      end
    end
  end
  
  def login
    
  end
end


def BTS.create
  BTS::Models.create_schema
end