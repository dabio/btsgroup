# coding:utf-8

helpers do
  include Rack::Utils
  alias :h :escape_html

  attr_accessor :current_person

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

      "<a href=\"#{href}\">#{h(trim[link_text, limit])}</a>" + punctuation.reverse.join('')
    end
  end

  def current_page
    @page = params[:page] && params[:page].match(/\d+/) ? params[:page].to_i : 1
  end

  def current_person
    @current_person = Person.first(:id => session[:person_id]) unless @current_person
    @current_person
  end

  def log_visit
    visit = Visit.first_or_create(:person => current_person)
    visit.updated_at = Time.now
    visit.save
  end

  def logged_in_as(person)
    session[:person_id] = person.id
  end

  def logged_in?
    !session[:person_id].nil?
  end

  def paginator(path)
    haml :pagination, :escape_html => false, :layout => false,
      :locals => {:path => path} if @count > 1
  end

  def require_login
    unless logged_in?
      session[:redirect] = request.fullpath
      redirect '/login'
    end
  end

  def simple_format(text)
    text = '' if text.nil?
    start_tag = '<p>'
    text.gsub!(/\r\n?/, "\n")
    text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />')
    text.insert(0, start_tag)
    text.concat("</p>")
  end

  def timesince(d, now=Time.now)
    delta = (now - d.to_time).to_i
    return '0 Minuten' if delta <= 60

    chunks = [
      [60 * 60 * 24 * 356, 'Jahr',   'Jahre'],
      [60 * 60 * 24 * 30,  'Monat',  'Monate'],
      [60 * 60 * 24 * 7,   'Woche',  'Wochen'],
      [60 * 60 * 24,       'Tag',    'Tage'],
      [60 * 60,            'Stunde', 'Stunden'],
      [60,                 'Minute', 'Minuten']
    ]

    ret = []
    pluralize = lambda {|amount, singular, plural| amount > 1 ? plural : singular}

    chunks.each do |seconds, singular, plural|
      amount, delta = delta.divmod(seconds)
      ret.push("#{amount} #{pluralize[amount, singular, plural]}") if amount > 0
      break if ret.length > 1
    end

    ret.join(', ')
  end
end

