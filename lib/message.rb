require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'


class Message
  include DataMapper::Resource

  belongs_to :person

  property :id,         Serial
  property :text,       Text,     :required => true, :lazy => false

  timestamps :at

  def self.display_messages(page)
    page -= 1  if page > 0
    all(:offset => page * BTS.messages_per_page,
        :limit => BTS.messages_per_page, :order => [:created_at.desc])
  end

end

