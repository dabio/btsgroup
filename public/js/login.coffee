login = (form, event) ->
    form = $(form)
    btn = form.find('button')
    # stop default submitting
    event.preventDefault()
    event.stopPropagation()
    # prevent double click
    btn.attr('disabled', 'disabled')
    # submit form with ajax
    $.ajax({
        url: form.attr('action'),
        method: form.attr('method'),
        data: form.serialize(),
        success: (resp) ->
            window.location = '/'
        error: (resp) ->
            alert('Benutzername oder Passwort ist falsch.')
            form.find('input[type=password]').val('').focus()
            btn.removeAttr('disabled')
    })

$('form').submit (e) ->
    login(this, e)
