# frozen_string_literal: true

require 'test_helper'

class HelperTest < ActionView::TestCase
  tests Dynaspan::ApplicationHelper

  setup do
    @user = create_user
  end

  def fragment(html)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  test 'renders the value as text with a hidden form that PATCHes the record' do
    html = fragment(dynaspan_text_field(@user, :name, unique_id: 'x'))

    assert_equal 'Ada Lovelace', html.at_css('#dyna_span_spanx').text
    assert_equal 'x', html.at_css('#dyna_span_blockx')['data-dynaspan']
    assert_includes html.at_css('#dyna_span_blockx')['class'], 'ds-content-present'
    assert_equal 'display:none;', html.at_css('#dyna_span_divx')['style']
    assert_equal 'Ada Lovelace', html.at_css('#last_dyna_span_val_x')['value']
    assert_nil html.at_css('#last_dyna_span_val_x')['name']

    form = html.at_css('#dyna_span_divx form')
    assert_equal "/users/#{@user.id}", form['action']
    assert_equal 'false', form['data-turbo']
    assert_equal 'patch', form.at_css('input[name=_method]')['value']

    input = form.at_css('input#dyna_span_field_val_x')
    assert_equal 'user[name]', input['name']
    assert_equal 'Ada Lovelace', input['value']
    assert_equal 'dyna-span form-control dyna-span-input', input['class']
    assert_nil input['onblur']
    assert_nil input['onfocus']
  end

  test 'generates a unique, selector safe id by default' do
    first = fragment(dynaspan_text_field(@user, :name)).at_css('.dyna-span[data-dynaspan]')['data-dynaspan']
    second = fragment(dynaspan_text_field(@user, :name)).at_css('.dyna-span[data-dynaspan]')['data-dynaspan']

    assert_match(/\AUser#{@user.id}name[0-9a-f]{6}\z/, first)
    refute_equal first, second
  end

  test 'renders the optional edit text' do
    html = fragment(dynaspan_text_field(@user, :title, '[edit]', unique_id: 'x'))
    assert_equal '[edit]', html.at_css('.dyna-span-edit-text').text

    html = fragment(dynaspan_text_field(@user, :title, unique_id: 'x'))
    assert_nil html.at_css('.dyna-span-edit-text')
  end

  test 'omits the content present class for blank values' do
    @user.title = ''
    html = fragment(dynaspan_text_field(@user, :title, unique_id: 'x'))
    refute_includes html.at_css('#dyna_span_blockx')['class'], 'ds-content-present'
  end

  test 'escapes the value' do
    @user.name = '<script>alert(1)</script>'
    html = dynaspan_text_field(@user, :name, unique_id: 'x')
    refute_includes html, '<script>'
    assert_equal '<script>alert(1)</script>', fragment(html).at_css('#dyna_span_spanx').text
  end

  test 'stores callbacks as escaped data attributes' do
    html = fragment(dynaspan_text_field(@user, :name, unique_id: 'x',
                                                      callback_on_update: %q{alert("saved");},
                                                      callback_with_values: "log('x');"))
    block = html.at_css('#dyna_span_blockx')
    assert_equal 'alert("saved");', block['data-ds-callback-on-update']
    assert_equal "log('x');", block['data-ds-callback-with-values']
  end

  test 'merges html options without allowing reserved attributes' do
    html = fragment(dynaspan_text_field(@user, :name, unique_id: 'x',
                                                      html_options: { class: 'wide', id: 'nope', onblur: 'nope()', placeholder: 'Name' }))
    input = html.at_css('input[name="user[name]"]')
    assert_equal 'dyna_span_field_val_x', input['id']
    assert_equal 'dyna-span form-control dyna-span-input wide', input['class']
    assert_equal 'Name', input['placeholder']
    assert_nil input['onblur']
  end

  test 'renders hidden fields' do
    html = fragment(dynaspan_text_field(@user, :name, unique_id: 'x', hidden_fields: { title: 'Countess' }))
    assert_equal 'Countess', html.at_css('input[type=hidden][name="user[title]"]')['value']
  end

  test 'allows overriding form options' do
    html = fragment(dynaspan_text_field(@user, :name, unique_id: 'x', form_for: { url: '/admin/users/1', html: { class: 'f' } }))
    form = html.at_css('form')
    assert_equal '/admin/users/1', form['action']
    assert_includes form['class'], 'f'
    assert_equal 'false', form['data-turbo']
  end

  test 'renders a text area' do
    html = fragment(dynaspan_text_area(@user, :bio, unique_id: 'x', html_options: { rows: 4 }))
    textarea = html.at_css('textarea#dyna_span_field_val_x')
    assert_equal 'user[bio]', textarea['name']
    assert_equal '4', textarea['rows']
    assert_equal 'First programmer.', textarea.text.strip
    assert_equal 'text_area', html.at_css('#dyna_span_blockx')['data-dynaspan-kind']
  end

  test 'renders a nested has_many attribute' do
    website = @user.websites.create!(url: 'https://example.com')
    html = fragment(dynaspan_text_field(@user, website, :url, '[edit]', unique_id: 'x'))

    assert_equal 'https://example.com', html.at_css('#dyna_span_spanx').text
    input = html.at_css('#dyna_span_field_val_x')
    assert_equal 'user[websites_attributes][0][url]', input['name']
    assert_equal website.id.to_s, html.at_css('input[name="user[websites_attributes][0][id]"]')['value']
  end

  test 'shows the nested value instead of falling back to the parent attribute' do
    website = @user.websites.build
    html = fragment(dynaspan_text_field(@user, website, :url, unique_id: 'x'))
    assert_equal '', html.at_css('#dyna_span_spanx').text
    assert_nil html.at_css('input[name="user[websites_attributes][0][id]"]')
  end

  test 'raises a helpful error without accepts_nested_attributes_for' do
    website = Website.new(user: @user)
    error = assert_raises(ArgumentError) { dynaspan_text_field(website, @user, :name) }
    assert_match(/accepts_nested_attributes_for/, error.message)
  end

  test 'raises a helpful error without an attribute symbol' do
    assert_raises(ArgumentError) { dynaspan_text_field(@user, 'name') }
  end

  test 'renders a select showing the label of the current value' do
    html = fragment(dynaspan_select(@user, :role, unique_id: 'x', choices: User::ROLES, options: { include_blank: true }))
    assert_equal 'Administrator', html.at_css('#dyna_span_spanx').text
    assert_equal 'admin', html.at_css('#last_dyna_span_val_x')['value']

    select = html.at_css('select#dyna_span_field_val_x')
    assert_equal 'user[role]', select['name']
    assert_equal 'admin', select.at_css('option[selected]')['value']
    assert_equal 4, select.css('option').size
  end

  test 'finds select labels in every choices format' do
    assert_equal 'Editor', dynaspan_choice_text({ 'Admin' => 'admin', 'Editor' => 'editor' }, 'editor')
    assert_equal 'b', dynaspan_choice_text(%w[a b], 'b')
    assert_equal 'Two', dynaspan_choice_text([['One', 1], ['Two', 2, { disabled: true }]], 2)
    assert_equal 'Canada', dynaspan_choice_text([['America', [%w[USA us], %w[Canada ca]]]], 'ca')
    assert_equal 'Editor', dynaspan_choice_text(options_for_select(User::ROLES), 'editor')
    assert_equal 'A & B', dynaspan_choice_text(options_for_select([['A & B', 'a"b']]), 'a"b')
    assert_nil dynaspan_choice_text(User::ROLES, 'missing')
    assert_nil dynaspan_choice_text(nil, 'x')
  end

  test 'falls back to the raw value for unknown select values' do
    @user.role = 'owner'
    html = fragment(dynaspan_select(@user, :role, unique_id: 'x', choices: User::ROLES))
    assert_equal 'owner', html.at_css('#dyna_span_spanx').text
  end

  test 'passes a block through to select' do
    html = fragment(dynaspan_select(@user, :role, unique_id: 'x') { tag.option('Custom', value: 'admin') })
    assert_equal 'Custom', html.at_css('select option').text
  end
end
