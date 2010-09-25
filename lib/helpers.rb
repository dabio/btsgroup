helpers do
  def current_page
    @page = params[:page] && params[:page].match(/\d+/) ? params[:page].to_i : 1
  end

  def current_person
    Person.first(:id => session[:person_id])
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

  def pluralize(singular, plural, amount)
      amount > 1 ? plural : singular
  end

  def require_login
    unless logged_in?
      session[:redirect] = request.fullpath
      redirect '/login'
    end
  end

  def timesince(d, now=Time.now)
    delta = (now - d).to_i
    return '0 Minuten' if delta <= 60

    chunks = [
      [60 * 60 * 24 * 356,  lambda {|n| pluralize('Jahr', 'Jahre', n)}],
      [60 * 60 * 24 * 30,   lambda {|n| pluralize('Monat', 'Monate', n)}],
      [60 * 60 * 24 * 7,    lambda {|n| pluralize('Woche', 'Wochen', n)}],
      [60 * 60 * 24,        lambda {|n| pluralize('Tag', 'Tage', n)}],
      [60 * 60,             lambda {|n| pluralize('Stunde', 'Stunden', n)}],
      [60,                  lambda {|n| pluralize('Minute', 'Minuten', n)}]
    ]

    ret = []

    chunks.each do |seconds, name|
      amount, delta = delta.divmod(seconds)
      ret.push("#{amount} #{name[amount]}") if amount > 0
      break if ret.length > 1
    end

    ret.join(', ')
  end
end

