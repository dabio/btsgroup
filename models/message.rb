# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

class Message
  include DataMapper::Resource

  property :id,     Serial
  property :text,   Text, required: true, lazy: false
  timestamps :at

  belongs_to :person, required: true

  def self.paginated(options={})
    page = options.delete(:page) || 1
    per_page = options.delete(:per_page) || 5

    options.reverse_merge!({
      :order => [:id.desc]
    })

    page_count = (count(options.except(:order)).to_f / per_page).ceil

    options.merge!({
      :limit => per_page,
      :offset => (page - 1) * per_page
    })

    [ page_count, all(options) ]
  end

end

