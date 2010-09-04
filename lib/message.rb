require 'dm-core'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-page-by-page'


class Message
  include DataMapper::Resource

  property :id,   Serial
  property :text, Text,   :required => true, :lazy => false
  timestamps :at

  belongs_to :person

  validates_presence_of :text

  is :paginated
end

