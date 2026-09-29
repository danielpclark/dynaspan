# frozen_string_literal: true

require 'test_helper'
require 'capybara/cuprite'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite, screen_size: [1024, 768], options: {
    headless: true,
    process_timeout: 30,
    browser_path: ENV.fetch('BROWSER_PATH', nil),
    browser_options: ENV['CI'] || Process.uid.zero? ? { 'no-sandbox' => nil } : {}
  }.compact

  def span(uid) = find("#dyna_span_span#{uid}")
  def field(uid) = find("#dyna_span_field_val_#{uid}")

  def wait_for_save(uid)
    assert_no_selector "#dyna_span_block#{uid}.ds-saving"
    assert_selector '#toast.toast-visible'
  end
end
