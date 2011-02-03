#
#   this is btsgroup.de, a cuba application
#   it is copyright (c) 2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

module Cuba::Prelude
  def slim(template, locals={}, &block)
    Slim::Template.new("views/#{template}.slim", locals, &block).render(self)
  end

  def stylesheet(template)
    if req.query_string =~ /^\w{5}$/
      res.headers['Cache-Control'] = 'public, max-age=29030400'
    end
    res.headers['Content-Type'] = 'text/css; charset=utf-8'
    render("views/#{template}")
  end
  # Wraps the common case of throwing a 404 page in a nice little helper.
  #
  # @example
  #
  #   on path("user"), segment do |_, id|
  #     break not_found unless user = User[id]
  #
  #     res.write user.username
  #   end
  def not_found
    res.status = 404
    res.write slim 404
  end
end

