require 'dm-core'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'
#require 'dm-is-page-by-page'

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:local.db')

class Visit
  include DataMapper::Resource

  property :id,   Serial
  timestamps :at

  belongs_to :person
end


class Person
  include DataMapper::Resource

  property :id,         Serial
  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :email,      String, :length => 255
  property :password,   BCryptHash
  timestamps :at

  has n, :messages
  has n, :visits

  attr_accessor :password_confirmation

  validates_confirmation_of :password, :if => :password_required?
  validates_uniqueness_of   :email

  def self.authenticate(email, password)
    return nil unless person = first(:email => email)
    person.password == password ? person : nil
  end

  private

    def password_required?
      !password.empty?
    end
end


class Message
  include DataMapper::Resource

  property :id,   Serial
  property :text, Text,   :required => true, :lazy => false
  timestamps :at

  belongs_to :person

  validates_presence_of :text

  def self.paginated(options = {})
    page = options.delete(:page) || 1
    per_page = options.delete(:per_page) || 5

    options.reverse_merge!({
      :order => [:id.desc]
    })

    page_count = (count(options.except(:order)).to_f / per_page).ceil

    options.merge!({
      :limit => per_page,
      :offset => (page - 1) * per_page
    })

    [ page_count, all(options) ]
  end
end

