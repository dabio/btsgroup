# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

class Person
  include DataMapper::Resource

  property :id,     Serial
  property :first_name, String, required: true
  property :last_name,  String, required: true
  property :email,      String, required: true, format: email, unique: true
  property :password,   BCryptHash, required: true
  timestamps :at

  has n, :messages
  has n, :visits

  attr_accessor :password_confirmation

  validates_confirmation_of :password, if: :password_required?


private
  def password_required?
    !password.empty?
  end
end

