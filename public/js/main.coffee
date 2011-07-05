class Notification
    max_request_ms = 30000
    next_request_ms = default_request_ms = 2000
    url = '/update.json'
    # reset some variables
    last_timestamp = active = active_timeout = false

    constructor: ->
        @reset()

    reset: ->
        next_request_ms = default_request_ms
        window.clearTimeout(active_timeout)
        pull() unless active

    pull = ->
        active = true
        data = if last_timestamp then "last_visit=#{last_timestamp}" else ''
        $.ajax({
            url: url,
            data: data,
            method: 'post',
            success: (resp) ->
                active = false
                update_next_request_ms()
                eval("(#{callback}(resp))") for callback in resp.callback
                active_timeout = window.setTimeout(pull, next_request_ms)
        })

    save_last_visit = (resp) ->
      last_timestamp = resp.last_visit

    update_next_request_ms = ->
        next_request_ms = next_request_ms * 2
        next_request_ms = max_request_ms if next_request_ms > max_request_ms

note = new Notification

show_messages = (resp) ->
  return true unless resp.messages or resp.messages.length < 1
  # get first visible message
  last_message = $('ul#messages > li.first')
  last_message.after(message) for message in resp.messages
  console.log(resp)


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

