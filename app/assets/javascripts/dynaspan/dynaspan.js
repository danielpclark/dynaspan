// Dynaspan: click-to-edit, in-place AJAX text editing for Rails.
// https://github.com/danielpclark/dynaspan
// MIT License. Copyright (c) 2014-2026 Daniel P. Clark
//
// Works with Sprockets (`//= require dynaspan/dynaspan`), Propshaft
// (`javascript_include_tag "dynaspan/dynaspan"`) and importmap-rails
// (`import "dynaspan"`). No jQuery, rails-ujs or Turbo required.
(function (window, document) {
  'use strict';

  if (!window || !document || (window.Dynaspan && window.Dynaspan.version)) return;

  var BLOCK_SELECTOR = '[data-dynaspan]';

  function parts(uid) {
    return {
      block: document.getElementById('dyna_span_block' + uid),
      container: document.getElementById('dyna_span_div' + uid),
      field: document.getElementById('dyna_span_field_val_' + uid),
      span: document.getElementById('dyna_span_span' + uid),
      last: document.getElementById('last_dyna_span_val_' + uid)
    };
  }

  function uidFor(element) {
    var block = element && element.closest && element.closest(BLOCK_SELECTOR);
    return block ? block.getAttribute('data-dynaspan') : null;
  }

  function dispatch(target, name, detail, cancelable) {
    var event = new CustomEvent('dynaspan:' + name, { bubbles: true, cancelable: !!cancelable, detail: detail });
    return target.dispatchEvent(event);
  }

  function fieldValue(field) {
    if (field.multiple) {
      return Array.prototype.map.call(field.selectedOptions, function (option) { return option.value; }).join(',');
    }
    return field.value;
  }

  function fieldText(field) {
    if (field.tagName === 'SELECT') {
      return Array.prototype.map.call(field.selectedOptions, function (option) { return option.text; }).join(', ');
    }
    return field.value;
  }

  function isTextInput(field) {
    return field.tagName === 'TEXTAREA' || (field.tagName === 'INPUT' && /^(text|search|url|tel|email|password)?$/i.test(field.type));
  }

  // Resets the field to the last value that was saved.
  function restore(uid) {
    var p = parts(uid);
    if (p.field && p.last && !p.field.multiple) p.field.value = p.last.value;
  }

  function show(uid) {
    var p = parts(uid);
    if (!p.block || !p.container || !p.field || !p.span) return;
    if (!p.block.classList.contains('ds-dialog-open')) {
      restore(uid);
      p.span.setAttribute('data-ds-display', p.span.style.display);
      p.span.style.display = 'none';
      p.container.style.display = '';
      p.block.classList.add('ds-dialog-open');
      dispatch(p.block, 'open', { selector: '#' + p.block.id, value: fieldValue(p.field) });
    }
    p.field.focus();
    if (isTextInput(p.field) && p.field.setSelectionRange) {
      var end = p.field.value.length;
      try { p.field.setSelectionRange(end, end); } catch (e) { /* not supported for this input type */ }
    }
  }

  function hide(uid, options) {
    options = options || {};
    var p = parts(uid);
    if (!p.block || !p.container || !p.field || !p.span) return;
    if (!p.block.classList.contains('ds-dialog-open')) return;

    if (options.cancel) restore(uid);

    var value = fieldValue(p.field);
    var text = fieldText(p.field);
    var changed = !options.cancel && (!p.last || p.last.value !== value);

    p.block.classList.remove('ds-dialog-open');
    p.container.style.display = 'none';
    p.span.style.display = p.span.getAttribute('data-ds-display') || '';

    if (changed) {
      p.span.textContent = text;
      if (p.last) p.last.value = value;
      p.block.classList.toggle('ds-content-present', text.length > 0);
      save(p, text, value);
    }

    dispatch(p.block, 'close', { selector: '#' + p.block.id, value: value, changed: changed });
  }

  // Appends a parameter to a JavaScript call written as a string:
  // "foo('a');" => "foo('a',param);"
  function appendParameter(command, param) {
    var withArgs = /\(([^)]+)\);?$/.exec(command);
    var withoutArgs = /\(\);?$/.exec(command);
    if (withArgs) return command.replace(withArgs[0], '(' + withArgs[1] + ',' + param + ');');
    if (withoutArgs) return command.replace(withoutArgs[0], '(' + param + ');');
    return command.replace(/;$/, '') + '(' + param + ');';
  }

  function runCallback(block, code, values) {
    try {
      if (values) {
        new Function('__dynaspan_values__', appendParameter(code, '__dynaspan_values__')).call(block, values);
      } else {
        new Function(code).call(block);
      }
    } catch (error) {
      if (window.console) window.console.error('Dynaspan callback failed:', error);
    }
  }

  function csrfToken(form) {
    var field = form.querySelector('input[name="authenticity_token"]');
    if (field && field.value) return field.value;
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : null;
  }

  function cspNonce() {
    var meta = document.querySelector('meta[name="csp-nonce"]');
    return meta ? meta.getAttribute('content') : null;
  }

  // Handles `update.turbo_stream.erb` and `update.js.erb` style responses.
  function handleResponse(response, body) {
    var type = response.headers.get('Content-Type') || '';
    if (/turbo-stream/.test(type) && window.Turbo && window.Turbo.renderStreamMessage) {
      window.Turbo.renderStreamMessage(body);
    } else if (/(java|ecma)script/.test(type) && body) {
      var script = document.createElement('script');
      var nonce = cspNonce();
      if (nonce) script.setAttribute('nonce', nonce);
      script.text = body;
      document.head.appendChild(script).parentNode.removeChild(script);
    }
  }

  function save(p, text, value) {
    var block = p.block;
    var form = p.container.querySelector('form');
    var detail = { selector: '#' + block.id, input: text, value: value, form: form };

    if (!form || !dispatch(block, 'update', detail, true)) return;

    var headers = {
      Accept: 'text/vnd.turbo-stream.html, text/javascript, application/javascript, application/json, text/html;q=0.9, */*;q=0.1',
      'X-Requested-With': 'XMLHttpRequest'
    };
    var token = csrfToken(form);
    if (token) headers['X-CSRF-Token'] = token;

    block.classList.add('ds-saving');
    block.classList.remove('ds-error');

    window.fetch(form.action, { method: 'POST', body: new FormData(form), headers: headers, credentials: 'same-origin' })
      .then(function (response) {
        return response.text().then(function (body) {
          if (!response.ok) {
            var error = new Error('Dynaspan update failed with HTTP status ' + response.status);
            error.response = response;
            throw error;
          }
          handleResponse(response, body);
          detail.response = response;
          dispatch(block, 'success', detail);
        });
      })
      .catch(function (error) {
        block.classList.add('ds-error');
        detail.error = error;
        detail.response = error.response;
        dispatch(block, 'error', detail);
      })
      .then(function () {
        block.classList.remove('ds-saving');
      });

    var withValues = block.getAttribute('data-ds-callback-with-values');
    if (withValues) runCallback(block, withValues, { ds_selector: '#' + block.id, ds_input: text });
    var onUpdate = block.getAttribute('data-ds-callback-on-update');
    if (onUpdate) runCallback(block, onUpdate);
  }

  function isTrigger(element) {
    return element.closest('.dyna-span-text, .dyna-span-edit-text');
  }

  function isInput(element) {
    return element.classList && element.classList.contains('dyna-span-input');
  }

  document.addEventListener('click', function (event) {
    var uid = uidFor(event.target);
    if (uid && isTrigger(event.target)) show(uid);
  });

  document.addEventListener('focusout', function (event) {
    var uid = uidFor(event.target);
    if (uid && isInput(event.target)) hide(uid);
  });

  document.addEventListener('keydown', function (event) {
    var target = event.target;
    var uid = uidFor(target);
    if (!uid) return;

    if (target.classList.contains('dyna-span-text')) {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        show(uid);
      }
      return;
    }

    if (!isInput(target)) return;

    var textarea = target.tagName === 'TEXTAREA';
    var submitKey = event.key === 'Enter' && (!textarea || event.ctrlKey || event.metaKey);
    if (event.key === 'Escape' || (submitKey && target.tagName !== 'SELECT')) {
      event.preventDefault();
      hide(uid, { cancel: event.key === 'Escape' });
      var span = parts(uid).span;
      if (span) span.focus();
    }
  });

  // Never let the browser, rails-ujs or Turbo submit a Dynaspan form.
  document.addEventListener('submit', function (event) {
    var uid = uidFor(event.target);
    if (!uid) return;
    event.preventDefault();
    event.stopPropagation();
    hide(uid);
  }, true);

  var Dynaspan = {
    version: '1.0.0',
    show: show,
    hide: function (uid) { hide(uid); },
    cancel: function (uid) { hide(uid, { cancel: true }); },
    appendParameter: appendParameter
  };
  window.Dynaspan = Dynaspan;

  // Backwards compatibility with the jQuery API of Dynaspan 0.x:
  // $().dynaspan.upShow(id), $().dynaspan.upHide(id), $().dynaspan.upLast(id)
  function installJQueryApi() {
    var $ = window.jQuery;
    if (!$ || !$.fn || $.fn.dynaspan) return;
    $.fn.dynaspan = function () { return this; };
    $.fn.dynaspan.upShow = show;
    $.fn.dynaspan.upHide = Dynaspan.hide;
    $.fn.dynaspan.upLast = restore;
    $.fn.dynaspan.appendParameter = appendParameter;
  }
  installJQueryApi();
  document.addEventListener('DOMContentLoaded', installJQueryApi);
})(typeof window !== 'undefined' ? window : undefined, typeof document !== 'undefined' ? document : undefined);
