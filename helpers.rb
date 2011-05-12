# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

module Helpers

  # Taken from rails
  AUTO_LINK_RE = %r{(?:([\w+.:-]+:)//|www\.)[^\s<]+}x
  BRACKETS = {']' => '[', ')' => '(', '}' => '{'}
  def auto_link(text, limit=nil)
    trim = lambda {|s, l| l != nil and (s.length > limit and "#{s[0,l-1]}…") or s}
    text.gsub(AUTO_LINK_RE) do
      scheme, href = $1, $&
      punctuation = []
      # don't include trailing punctiation character as part of the URL
      while href.sub!(/[^\w\/-]$/, '')
        punctuation.push $&
        if opening = BRACKETS[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
          href << punctuation.pop
          break
        end
      end

      link_text = block_given? ? yield(href) : href
      href = 'http://' + href unless scheme

      "<a href=\"#{href}\">#{trim[link_text, limit]}</a>" + punctuation.reverse.join('')
    end
  end

  # This gives us the currently logged in user. We keep track of that by just
  # setting a session variable with their is. If it doesn't exist, we want to
  # return nil.
  def current_person
    @cp = Person.first(id: session[:person_id]) if session[:person_id] unless @cp
    @cp
  end

  # Checks if this is a logged in person
  def has_auth?
    !current_person.nil?
  end

  def simple_format str
    str = '' if str.nil?
    start_tag = '<p>'
    end_tag = '</p>'
    str.gsub! /\r\n?/, "\n"
    str.gsub! /\n\n+/, "#{end_tag}\n\n#{start_tag}"
    str.gsub! /([^\n]\n)(?=[^\n])/, '\1<br />'
    str.insert 0, start_tag
    str.concat end_tag
  end

  def today
    @today = Date.today unless @today
    @today
  end

end

class BTS
  helpers do
    include Helpers
  end
end

