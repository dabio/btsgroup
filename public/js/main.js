(function() {
  var Notification, form_method, note, submit_form;
  Notification = (function() {
    var active, active_timeout, default_request_ms, last_timestamp, max_request_ms, next_request_ms, pull, update_next_request_ms, url;
    max_request_ms = 30000;
    next_request_ms = default_request_ms = 2000;
    url = '/pull';
    last_timestamp = 123;
    active = false;
    active_timeout = false;
    function Notification() {
      this.reset();
    }
    Notification.prototype.reset = function() {
      next_request_ms = default_request_ms;
      window.clearTimeout(active_timeout);
      if (!active) {
        return pull();
      }
    };
    pull = function() {
      active = true;
      return $.ajax({
        url: url,
        method: 'get',
        success: function(resp) {
          active = false;
          update_next_request_ms();
          active_timeout = window.setTimeout(pull, next_request_ms);
          return console.log(resp);
        }
      });
    };
    update_next_request_ms = function() {
      next_request_ms = next_request_ms * 2;
      if (next_request_ms > max_request_ms) {
        return next_request_ms = max_request_ms;
      }
    };
    return Notification;
  })();
  note = new Notification;
  submit_form = function(form, event) {
    var btn, btn_text_before;
    form = $(form);
    btn = form.find('button');
    btn_text_before = btn.text();
    event.preventDefault();
    event.stopPropagation();
    btn.text('Wird gespeichert').attr('disabled', 'disabled');
    return $.ajax({
      url: form.attr('action'),
      method: form_method(form),
      data: form.serialize(),
      success: function(resp) {
        btn.text(btn_text_before).removeAttr('disabled');
        if (form.find('textarea').length > 0) {
          form.find('textarea').val('');
        }
        return note.reset();
      },
      error: function(err) {
        alert('Ein Fehler ist aufgetreten. Bitte erneut speichern.');
        return btn.text(btn_text_before).removeAttr('disabled');
      }
    });
  };
  form_method = function(form) {
    if (form.find('input[name=_method]').length > 0) {
      return form.find('input[name=_method]').val();
    } else {
      return form.attr('method');
    }
  };
  $('form').submit(function(e) {
    return submit_form(this, e);
  });
}).call(this);
