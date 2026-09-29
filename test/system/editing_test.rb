# frozen_string_literal: true

require 'application_system_test_case'

class EditingTest < ApplicationSystemTestCase
  setup do
    @user = create_user(title: 'Analyst')
    @website = @user.websites.create!(url: 'https://example.com/ada')
  end

  test 'clicking the text swaps in a field and blurring saves it' do
    visit user_path(@user)

    assert_no_selector '#dyna_span_field_val_name'
    span('name').click

    assert_selector '#dyna_span_blockname.ds-dialog-open'
    assert_no_selector '#dyna_span_spanname'
    assert_equal field('name'), page.active_element

    field('name').fill_in(with: 'Augusta Ada King')
    find('.hint').click

    assert_selector '#dyna_span_spanname', text: 'Augusta Ada King'
    assert_no_selector '#dyna_span_field_val_name'
    wait_for_save('name')
    assert_equal 'Augusta Ada King', @user.reload.name
  end

  test 'enter saves and escape cancels' do
    visit user_path(@user)

    span('title').click
    field('title').fill_in(with: 'Countess of Lovelace')
    field('title').send_keys(:enter)

    assert_selector '#dyna_span_spantitle', text: 'Countess of Lovelace'
    wait_for_save('title')
    assert_equal 'Countess of Lovelace', @user.reload.title
    assert_equal span('title'), page.active_element

    span('title').click
    field('title').fill_in(with: 'Thrown away')
    field('title').send_keys(:escape)

    assert_selector '#dyna_span_spantitle', text: 'Countess of Lovelace'
    span('title').click
    assert_equal 'Countess of Lovelace', field('title').value
  end

  test 'the keyboard can open a field' do
    visit user_path(@user)

    execute_script("document.getElementById('dyna_span_spantitle').focus()")
    page.driver.browser.keyboard.type(:Enter)

    assert_selector '#dyna_span_blocktitle.ds-dialog-open'
    assert_equal field('title'), page.active_element
  end

  test 'unchanged values are not sent to the server' do
    visit playground_user_path(@user)

    span('callbacks').click
    find('.hint').click

    assert_no_selector '#dyna_span_blockcallbacks.ds-dialog-open'
    assert_no_selector '#log li'
  end

  test 'selects show the chosen label' do
    visit user_path(@user)

    assert_selector '#dyna_span_spanrole', text: 'Administrator'
    span('role').click
    field('role').select('Editor')
    find('.hint').click

    assert_selector '#dyna_span_spanrole', text: 'Editor'
    wait_for_save('role')
    assert_equal 'editor', @user.reload.role
  end

  test 'text areas keep line breaks' do
    visit user_path(@user)

    span('bio').click
    field('bio').fill_in(with: "Line one\nLine two")
    field('bio').send_keys([:control, :enter])

    assert_selector '#dyna_span_spanbio', text: "Line one\nLine two"
    wait_for_save('bio')
    assert_equal "Line one\r\nLine two", @user.reload.bio
  end

  test 'nested attributes are saved through the parent record' do
    visit user_path(@user)

    span('website').click
    field('website').fill_in(with: 'https://example.com/lovelace')
    find('.hint').click

    wait_for_save('website')
    assert_equal 'https://example.com/lovelace', @website.reload.url
    assert_equal 1, @user.websites.count
  end

  test 'validation failures are flagged' do
    visit user_path(@user)

    span('name').click
    field('name').fill_in(with: '')
    find('.hint').click

    assert_selector '#dyna_span_blockname.ds-error'
    assert_selector '#toast.toast-error', text: 'Could not save'
    refute_selector '#dyna_span_blockname.ds-content-present'
    assert_equal 'Ada Lovelace', @user.reload.name
  end

  test 'runs callbacks and dispatches events' do
    visit playground_user_path(@user)

    find('#dyna_span_blockcallbacks .dyna-span-edit-text').click
    field('callbacks').fill_in(with: %q{O'Brien "quoted"})
    field('callbacks').send_keys(:enter)

    assert_selector '#log li', count: 3
    assert_equal ["event O'Brien \"quoted\"", "with #dyna_span_blockcallbacks O'Brien \"quoted\"", 'updated'],
                 all('#log li').map(&:text)
    assert_selector '#dyna_span_spancallbacks', text: %q{O'Brien "quoted"}
    assert_no_selector '#dyna_span_blockcallbacks.ds-saving'
    assert_equal %q{O'Brien "quoted"}, @user.reload.name
  end

  test 'user input is displayed as text, not html' do
    visit user_path(@user)

    span('title').click
    field('title').fill_in(with: '<b>bold</b>')
    field('title').send_keys(:enter)

    assert_selector '#dyna_span_spantitle', text: '<b>bold</b>'
    assert_no_selector '#dyna_span_spantitle b'
  end

  test 'request errors are flagged' do
    visit playground_user_path(@user)

    find('#dyna_span_blockblank .dyna-span-edit-text').click
    field('blank').fill_in(with: 'Nowhere')
    field('blank').send_keys(:enter)

    assert_selector '#dyna_span_blockblank.ds-error'
    assert_equal 'Analyst', @user.reload.title
  end

  test 'fields can be controlled from JavaScript' do
    visit user_path(@user)

    execute_script("Dynaspan.show('title')")
    assert_selector '#dyna_span_blocktitle.ds-dialog-open'
    field('title').fill_in(with: 'Discarded')
    execute_script("Dynaspan.cancel('title')")
    assert_selector '#dyna_span_spantitle', text: 'Analyst'

    execute_script("Dynaspan.show('title')")
    field('title').fill_in(with: 'Kept')
    execute_script("Dynaspan.hide('title')")
    assert_selector '#dyna_span_spantitle', text: 'Kept'
    wait_for_save('title')
    assert_equal 'Kept', @user.reload.title
  end
end
