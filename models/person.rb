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
  property :email,      String, required: true, format: :email_address, unique: true
  property :password,   BCryptHash, required: true
  timestamps :at

  has n, :messages
  has n, :visits


  def avatar_url
    "/people/#{first_name}.png"
  end


  def self.authenticate(email, password)
    return nil unless person = Person.first(email: email)
    person.password == password ? person : nil
  end

end

