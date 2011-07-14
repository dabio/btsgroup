(function() {
  var Notification, form_method, note, outerHTML, show_messages, submit_form, update_messages, update_visits;
  Notification = (function() {
    var active, active_timeout, default_request_ms, get_data, get_url_parameter, last_timestamp, max_request_ms, next_request_ms, notes, page_title, pull, save_last_visit, update_next_request_ms, url;
    max_request_ms = 30000;
    next_request_ms = default_request_ms = 2000;
    url = '/update.json';
    last_timestamp = active = active_timeout = false;
    notes = 0;
    page_title = '';
    function Notification() {
      page_title = document.title;
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
        data: get_data(),
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
    get_data = function() {
      var data, page;
      data = '';
      page = get_url_parameter('page');
      if (page) {
        data = "page=" + page + "&";
      }
      if (data.length > 0) {
        data = "&" + data;
      }
      if (last_timestamp) {
        data = "" + data + "last_visit=" + last_timestamp;
      }
      return data;
    };
    save_last_visit = function(resp) {
      return last_timestamp = resp.last_visit;
    };
    get_url_parameter = function(name) {
      return decodeURI((RegExp("" + name + "=(.+?)(&|$)").exec(location.search) || ['', null])[1]);
    };
    update_next_request_ms = function() {
      next_request_ms = next_request_ms * 2;
      if (next_request_ms > max_request_ms) {
        return next_request_ms = max_request_ms;
      }
    };
    Notification.prototype.update_page_title = function(count) {
      notes = notes + count;
      if (notes > 0) {
        return document.title = "(" + notes + ") " + page_title;
      }
    };
    return Notification;
  })();
  note = new Notification;
  show_messages = function(resp) {
    var latest_message, message, _i, _len, _ref, _results;
    if (!(resp.messages || resp.messages.length < 1)) {
      return true;
    }
    latest_message = $('ul#messages > li.first');
    _ref = resp.messages;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      message = _ref[_i];
      latest_message.after(message);
      $('ul#messages > li').last().remove();
      _results.push($('ul#messages > li.hidden').css('opacity', 0).removeClass('hidden').animate({
        opacity: 1,
        duration: 500
      }));
    }
    return _results;
  };
  outerHTML = function(node) {
    return node.outerHTML || function(n) {
        var div = document.createElement('div'), h;
        div.appendChild(n.cloneNode(true));
        h = div.innerHTML;
        div = null;
        return h;
    }(node);
  };
  update_messages = function(resp) {
    var i, last_messages, message, _len, _ref, _results;
    if (!(resp.messages || resp.messages.length < 1)) {
      return true;
    }
    last_messages = $('ul#messages > li');
    if ($('ul#messages > li.first').length > 0) {
      last_messages.shift();
    }
    if (last_messages.length === resp.messages.length) {
      _ref = resp.messages;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        message = _ref[i];
        _results.push(outerHTML(last_messages[i]) !== message ? $(last_messages[i]).after(message).remove() : void 0);
      }
      return _results;
    }
  };
  update_visits = function(resp) {
    var i, last_visits, outerhtml, visit, _len, _ref, _results;
    if (!(resp.visits || resp.visits.length < 1)) {
      return true;
    }
    last_visits = $('ul#visits > li');
    if (last_visits.length === resp.visits.length) {
      _ref = resp.visits;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        visit = _ref[i];
        outerhtml = outerHTML(last_visits[i]);
        _results.push(outerHTML(last_visits[i]) !== visit ? $(last_visits[i]).after(visit).remove() : void 0);
      }
      return _results;
    }
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
  window.onerror = function(msg, url, line) {};
}).call(this);
