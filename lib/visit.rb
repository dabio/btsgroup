require 'dm-core'
require 'dm-timestamps'
require 'dm-types'


class Visit
  include DataMapper::Resource

  property :id,   Serial
  property :url,  URI
  timestamps :at

  belongs_to :person
end
