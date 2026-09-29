# Changelog

## 1.0.0

Dynaspan is now a modern Rails engine for Rails 7.1 through 8.x. The helper API
(`dynaspan_text_field`, `dynaspan_text_area`, `dynaspan_select`) and its options
are unchanged.

### Added

- Dependency-free JavaScript. jQuery, rails-ujs and jquery_ujs are no longer
  required. Updates are sent with `fetch` and include the CSRF token.
- Works with importmap-rails (`import "dynaspan"`, pinned automatically),
  Propshaft and Sprockets.
- Keyboard support. The text can be reached with <kbd>Tab</kbd> and opened with
  <kbd>Enter</kbd> or <kbd>Space</kbd>. <kbd>Enter</kbd> saves a text field,
  <kbd>Ctrl</kbd>/<kbd>⌘</kbd>+<kbd>Enter</kbd> saves a text area and
  <kbd>Esc</kbd> cancels the edit.
- DOM events: `dynaspan:open`, `dynaspan:close`, `dynaspan:update`
  (cancelable), `dynaspan:success` and `dynaspan:error`.
- `ds-saving` and `ds-error` CSS classes on the Dynaspan block.
- Turbo Stream (`update.turbo_stream.erb`) and JavaScript (`update.js.erb`)
  responses are applied to the page.
- An optional stylesheet: `dynaspan/dynaspan.css`.
- `window.Dynaspan.show(id)`, `.hide(id)` and `.cancel(id)` for scripting.
- A test suite (helper and browser tests) and CI across Rails 7.1–8.1.

### Changed

- Requires Ruby 3.1+ and Rails 7.1+.
- Helpers are available in every view automatically. You no longer need to
  `include Dynaspan::ApplicationHelper` (keeping it does no harm).
- Inline `onclick`/`onblur`/`onfocus` handlers were replaced by delegated event
  listeners, so Dynaspan works with a `script-src` Content Security Policy
  that disallows inline scripts (`callback_on_update` and
  `callback_with_values` still need `unsafe-eval`).
- A request is sent only when the value actually changed.
- The three partials were merged into `dynaspan/_dynaspan.html.erb`.
- Forms get `data-turbo="false"` and are no longer marked `remote: true`.
  Dynaspan submits them itself.
- For a `has_many` nested record the parameters are now sent as
  `parent[children_attributes][0][attribute]`, which also works for new
  (unsaved) nested records.
- The `[edit]` element is rendered only when edit text is given.

### Fixed

- User input is displayed as text, never as HTML.
- `callback_with_values` works when the entered text contains quotes.
- Callback strings are HTML escaped in the data attributes.
- Reserved `html_options` (`:id`, `:onblur`, `:onfocus`) are really removed.
- Ids generated for namespaced models (`Admin::User`) are valid selectors.
- A blank nested value no longer displays the parent record's attribute of
  the same name.
- `dynaspan_select` finds the label for hash, grouped and pre-rendered
  (`options_for_select`) choices without building a regular expression from
  user data.
- A nested record without `accepts_nested_attributes_for` raises a helpful
  `ArgumentError` instead of silently editing the parent record.
- `helper` is no longer called on `ActionController::API` controllers.

### Removed

- Rails 3/4 specific code, the unused `basepath.js.erb`, `dynaspan-jquery.js`
  and the `assets:precompile` non-digest rake task.

## 0.1.5 / 0.1.4

- `dynaspan_select` displays the option label rather than its value.
- Safeguard for enum values.

## 0.1.3

- `:unique_id` defaults to an id based on the record plus random characters.
- Added `:html_options`.
- Added `dynaspan_select` with `:choices`, `:options` and block support.

## 0.1.2

- Added `:unique_id` and `:form_for` options.

## 0.1.1

- Added `:callback_with_values`.

## 0.1.0

- `:hidden_fields` work for non-nested records.

## 0.0.9

- Added `:callback_on_update`.

## 0.0.8

- Options hash with `:hidden_fields` for nested records.
- The nested record id is only sent when it exists, allowing new nested records.

## 0.0.7

- `ds-dialog-open` class while the field is open.

## 0.0.6

- `ds-content-present` class when the field has content.
