require 'camping'
require 'camping/session'
require 'digest/sha1'

Camping.goes :BTS


module BTS
  include Camping::Session

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
  
  def messages_per_page
    config[:messages_per_page]
  end
end


module BTS::Models
  class User < Base
    has_many :messages
    
    def encrypt_password(plain_password)
      algo = 'sha1'
      salt = Array.new(3) { rand(256) }.pack('C*').unpack('H*').first
      hash = Digest::SHA1.hexdigest(salt + plain_password)
      [algo, salt, hash].join('$')
    end
    
    def check_password(plain_password)
      algo, salt, hash = self.password.split("$")
      hash == Digest::SHA1.hexdigest(salt + plain_password)
    end
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
      requires_login!
      if (page = @input.page.to_i) > 0
        page -= 1
      end
      # fetch messages
      @messages = Message.all :offset => page * BTS.messages_per_page,
        :limit => BTS.messages_per_page, :order => "created_at DESC"
      render :list
    end
  end
  
  class Login
    def get
      render :login
    end
    
    def post
      @user = User.find_by_email(@input.email)
      if @user and @user.check_password(@input.password)
        @state.current_user = @user
        redirect Index
      else
        @state.flash = "Anmeldung fehlgeschlagen!"
        redirect Login
      end
    end
  end
  
  class Logout
    def get
      requires_login!
      @state.user = nil
      redirect Login
    end
  end
  
  class Settings
    def get
      requires_login!
      render :settings
    end
    
    def post
      requires_login!
      current_user.email = @input.email
      if current_user.check_password(@input.old_password)
        if @input.new_password == @input.confirm_password
          current_user.password = current_user.encrypt_password(@input.new_password)
        else
          @state.flash = "Passwörter stimmen nicht überein"
          redirect Settings
          throw :halt
        end
      end
      current_user.save
      @state.flash = "Einstellungen gesichert."
      redirect Index
    end
  end
end


module BTS::Views
  def layout
    xhtml_strict
    html do
      head do
        title BTS.title
        link :rel => "stylesheet", :href => self / "/css/style.css"
      end
      body do
        header
        navigation
        flash
        self << yield
      end
    end
  end
  
  def header
    if @current_user
      div :class => "header" do
        span "Hallo " << @current_user.first_name, :class => "current_user"
        span :class => "settings" do
          a "Einstellungen", :href => R(Settings)
        end
        span :class => "logout" do
          a "Abmelden", :href => R(Logout)
        end
      end
    end
  end
  
  def navigation
    if @current_user
    end
  end
  
  def flash
    if @state.flash
      div @state.flash, :class => "flash"
      @state.flash = nil
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
      a "next", :href => R(Index, :page => @input.page.to_i + 1)
    end
  end
  
  def login
    form :action => R(Login), :method => "post" do
      label "E-Mail", :for => "email"
      input :name => "email", :type => "email" #, :autofocus => "autofocus"
      label "Passwort", :for => "password"
      input :name => "password", :type => "password"
      button "Anmelden", :type => "submit"
    end
  end
  
  def settings
    form :action => R(Settings), :method => "post" do
      label "E-Mail", :for => "email"
      input :name => "email", :type => "email", :value => @current_user.email
      label "Altes Passwort", :for => "old_password"
      input :name => "old_password", :type => "password"
      label "Neues Passwort", :for => "new_password"
      input :name => "new_password", :type => "password"
      label "Passwort wiederholen", :for => "confirm_password"
      input :name => "confirm_password", :type => "password"
      button "Speichern", :type => "submit"
    end
  end
end


module BTS::Helpers
  def requires_login!
    unless current_user
      redirect BTS::Controllers::Login
      throw :halt
    end
  end
  
  def current_user
    @current_user ||= state.current_user
  end
end


def BTS.create
  BTS::Models.create_schema
end