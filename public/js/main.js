(function() {
  var Notification, form_method, note, show_messages, submit_form;
  Notification = (function() {
    var active, active_timeout, default_request_ms, last_timestamp, max_request_ms, next_request_ms, pull, save_last_visit, update_next_request_ms, url;
    max_request_ms = 30000;
    next_request_ms = default_request_ms = 2000;
    url = '/update.json';
    last_timestamp = active = active_timeout = false;
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
      var data;
      active = true;
      data = last_timestamp ? "last_visit=" + last_timestamp : '';
      return $.ajax({
        url: url,
        data: data,
        method: 'post',
        success: function(resp) {
          var callback, _i, _len, _ref;
          active = false;
          update_next_request_ms();
          _ref = resp.callback;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            callback = _ref[_i];
            eval("(" + callback + "(resp))");
          }
          return active_timeout = window.setTimeout(pull, next_request_ms);
        }
      });
    };
    save_last_visit = function(resp) {
      return last_timestamp = resp.last_visit;
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
  show_messages = function(resp) {
    var last_message, message, _i, _len, _ref;
    if (!(resp.messages || resp.messages.length < 1)) {
      return true;
    }
    last_message = $('ul#messages > li.first');
    _ref = resp.messages;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      message = _ref[_i];
      last_message.after(message);
    }
    return console.log(resp);
  };
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
