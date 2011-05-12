# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

class Visit
  include DataMapper::Resource

  property :person_id, Integer, key: true
  timestamps :at

  belongs_to :person
end

