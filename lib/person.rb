#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

require 'dm-core'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'

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

  def avatar_url
    "#{settings.cdn}people/#{first_name}.png"
  end

  private

    def password_required?
      !password.empty?
    end
end

