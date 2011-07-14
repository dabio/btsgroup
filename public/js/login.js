(function() {
  var login;
  login = function(form, event) {
    var btn;
    form = $(form);
    btn = form.find('button');
    event.preventDefault();
    event.stopPropagation();
    btn.attr('disabled', 'disabled');
    return $.ajax({
      url: form.attr('action'),
      method: form.attr('method'),
      data: form.serialize(),
      success: function(resp) {
        return window.location = '/';
      },
      error: function(resp) {
        alert('Benutzername oder Passwort ist falsch.');
        form.find('input[type=password]').val('').focus();
        return btn.removeAttr('disabled');
      }
    });
  };
  $('form').submit(function(e) {
    return login(this, e);
  });
}).call(this);
