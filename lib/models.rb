require 'dm-core'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'
require 'dm-is-page-by-page'


class Person
  include DataMapper::Resource

  property :id,         Serial
  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :email,      String, :length => 255
  property :password,   BCryptHash
  property :birthday,   DateTime
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

  is :paginated
end


class Visit
  include DataMapper::Resource

  property :id,   Serial
  property :url,  URI
  timestamps :at

  belongs_to :person
end
