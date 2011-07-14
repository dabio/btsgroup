class Notification
    max_request_ms = 30000
    next_request_ms = default_request_ms = 2000
    url = '/update.json'
    # reset some variables
    last_timestamp = active = active_timeout = false
    notes = 0
    page_title = ''

    constructor: ->
        page_title = document.title
        @reset()

    reset: ->
        next_request_ms = default_request_ms
        window.clearTimeout(active_timeout)
        pull() unless active

    pull = ->
        active = true
        $.ajax({
            url: url,
            data: get_data(),
            method: 'post',
            success: (resp) ->
                active = false
                update_next_request_ms()
                eval("(#{callback}(resp))") for callback in resp.callback
                active_timeout = window.setTimeout(pull, next_request_ms)
        })

    get_data = ->
        data = ''
        page = get_url_parameter('page')
        data = "page=#{page}&" if page
        data = "&#{data}" if data.length > 0
        data = "#{data}last_visit=#{last_timestamp}" if last_timestamp
        return data

    save_last_visit = (resp) ->
        last_timestamp = resp.last_visit

    get_url_parameter = (name) ->
        decodeURI((RegExp("#{name}=(.+?)(&|$)").exec(location.search)||['',null])[1])

    update_next_request_ms = ->
        next_request_ms = next_request_ms * 2
        next_request_ms = max_request_ms if next_request_ms > max_request_ms

    update_page_title: (count) ->
        notes = notes + count
        document.title = "(#{notes}) #{page_title}" if notes > 0


note = new Notification


show_messages = (resp) ->
  return true unless resp.messages or resp.messages.length < 1
  latest_message = $('ul#messages > li.first')
  # add new messages and remove the corresponding last messages at this page
  for message in resp.messages
    latest_message.after(message)
    $('ul#messages > li').last().remove()

    $('ul#messages > li.hidden')
        .css('opacity', 0)
        .removeClass('hidden')
        .animate({
      opacity: 1,
      duration: 500
    })

outerHTML = (node) ->
    # if IE and Chrome then take the internal method, otherwise build one
    return node.outerHTML or `function(n) {
        var div = document.createElement('div'), h;
        div.appendChild(n.cloneNode(true));
        h = div.innerHTML;
        div = null;
        return h;
    }(node)`


update_messages = (resp) ->
  return true unless resp.messages or resp.messages.length < 1
  last_messages = $('ul#messages > li')
  last_messages.shift() if $('ul#messages > li.first').length > 0
  if last_messages.length == resp.messages.length
    for message, i in resp.messages
      if outerHTML(last_messages[i]) != message
        $(last_messages[i]).after(message).remove()


update_visits = (resp) ->
  return true unless resp.visits or resp.visits.length < 1
  last_visits = $('ul#visits > li')
  if last_visits.length == resp.visits.length
    for visit, i in resp.visits
      outerhtml = outerHTML(last_visits[i])
      $(last_visits[i]).after(visit).remove() if outerHTML(last_visits[i]) != visit


submit_form = (form, event) ->
    form = $(form)
    btn = form.find('button')
    btn_text_before = btn.text()
    # stop default submitting
    event.preventDefault()
    event.stopPropagation()
    # prevent double clicking
    btn.text('Wird gespeichert').attr('disabled', 'disabled')
    # submit form with ajax
    $.ajax({
        url: form.attr('action'),
        method: form_method(form),
        data: form.serialize(),
        success: (resp) ->
            btn.text(btn_text_before).removeAttr('disabled')
            form.find('textarea').val('') if form.find('textarea').length > 0
            note.reset()
        error: (err) ->
            alert('Ein Fehler ist aufgetreten. Bitte erneut speichern.')
            btn.text(btn_text_before).removeAttr('disabled')
    })


# gets the default action of a form either from the form attribute or from the
# hidden input field named _method
form_method = (form) ->
    if form.find('input[name=_method]').length > 0
        form.find('input[name=_method]').val()
    else
        form.attr('method')


$('form').submit (e) ->
    submit_form(this, e)


window.onerror = (msg, url, line) ->

