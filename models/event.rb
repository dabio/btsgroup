# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

class Event
  include DataMapper::Resource

  property :id,         Serial
  property :time,       Date, required: true
  property :recurrence, Enum[:once, :yearly], default: :once
  timestamps :at

  has n, :event_links

  after :save do |event|
    if event.recurrence == :yearly
      # build all event_links for passed events and for the next 10 years
      (event.time.year..(Date.today.year+10)).each do |year|
        l = Date.new(year, event.time.month, event.time.day)
        link = event.event_links.new(time: l)
        link.save
      end
    end
  end

end


class EventLink
  include DataMapper::Resource

  property :id,     Serial
  property :time,   Date,   required: true

  belongs_to :event
end

