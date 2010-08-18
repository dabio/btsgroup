require 'dm-core'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'


class Person
  include DataMapper::Resource

  has n, :messages

  property :id,         Serial
  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :email,      String, :length => 255
  property :password,   BCryptHash
  property :birthday,   DateTime
  property :last_seen,  DateTime

  timestamps :at

  attr_accessor :password_confirmation

  validates_confirmation_of :password, :if => :password_required?
  validates_uniqueness_of   :email

  def self.authenticate(email, password)
    return nil unless person = first(:email => email)
    person.password == password ? person : nil
  end

  private

   def password_required?
     password.blank? or !password.blank?
   end

end