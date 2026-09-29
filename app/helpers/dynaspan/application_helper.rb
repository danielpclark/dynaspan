# frozen_string_literal: true

require 'securerandom'

module Dynaspan
  # View helpers that render a piece of text which turns into a form field
  # when clicked and saves itself over AJAX when the field loses focus.
  #
  # Every helper takes the same arguments:
  #
  #   dynaspan_text_field(record, :attribute)
  #   dynaspan_text_field(record, :attribute, '[edit]', options)
  #   dynaspan_text_field(record, nested_record, :attribute, '[edit]', options)
  #
  # See the README for the full list of options.
  module ApplicationHelper
    RESERVED_HTML_OPTIONS = %w[id onblur onfocus].freeze
    INPUT_CLASSES = 'dyna-span form-control dyna-span-input'

    def dynaspan_text_field(master_ds_object, *parameters)
      dynaspan_render(:text_field, master_ds_object, parameters)
    end

    def dynaspan_text_area(master_ds_object, *parameters)
      dynaspan_render(:text_area, master_ds_object, parameters)
    end

    def dynaspan_select(master_ds_object, *parameters, &block)
      dynaspan_render(:select, master_ds_object, parameters, &block)
    end

    private

    def dynaspan_render(kind, master_ds_object, parameters, &block)
      raise ArgumentError, 'Dynaspan needs a record to update as its first argument.' if master_ds_object.nil?

      parameters = parameters.dup
      options = parameters.last.is_a?(Hash) ? parameters.pop.with_indifferent_access : ActiveSupport::HashWithIndifferentAccess.new
      attr_object, attrib, edit_text = dynaspan_parse_arguments(parameters)

      association = dynaspan_nested_association(master_ds_object, attr_object)
      target = attr_object || master_ds_object
      value = target.public_send(attrib)
      unique_ref_id = options.fetch(:unique_id) { dynaspan_unique_id(master_ds_object, attr_object, attrib) }.to_s
      choices = options[:choices]

      render(
        partial: 'dynaspan/dynaspan',
        locals: {
          kind: kind,
          master_ds_object: master_ds_object,
          attr_object: attr_object,
          association: association,
          attrib: attrib,
          value: value,
          display_text: kind == :select ? dynaspan_choice_text(choices, value) || value : value,
          unique_ref_id: unique_ref_id,
          dyna_span_edit_text: edit_text,
          hidden_fields: options[:hidden_fields] || {},
          ds_callback_on_update: options[:callback_on_update],
          ds_callback_with_values: options[:callback_with_values],
          form_for_options: dynaspan_form_options(options[:form_for]),
          choices: choices,
          select_options: (options[:options] || {}).to_h.symbolize_keys,
          html_options: dynaspan_html_options(options[:html_options], kind, unique_ref_id),
          block: block
        }
      )
    end

    # Accepts (attribute, edit_text?) or (nested_record, attribute, edit_text?).
    def dynaspan_parse_arguments(parameters)
      if parameters.first.is_a?(Symbol)
        attr_object = nil
        attrib, edit_text = parameters
      elsif parameters[1].is_a?(Symbol)
        attr_object, attrib, edit_text = parameters
      else
        raise ArgumentError, 'Dynaspan needs a Symbol naming the attribute to edit, e.g. dynaspan_text_field(user, :name).'
      end

      [attr_object, attrib, edit_text.is_a?(String) ? edit_text : nil]
    end

    # Finds the `accepts_nested_attributes_for` association on the master
    # record that the nested record belongs to.
    def dynaspan_nested_association(master_ds_object, attr_object)
      return if attr_object.nil?

      klass = master_ds_object.class
      names = klass.respond_to?(:nested_attributes_options) ? klass.nested_attributes_options.keys.map(&:to_s) : []

      name = names.find do |association_name|
        reflection = klass.try(:reflect_on_association, association_name)
        reflection && !reflection.polymorphic? && attr_object.is_a?(reflection.klass)
      end

      name ||= begin
        model_name = attr_object.class.model_name
        candidates = [model_name.singular, model_name.plural, model_name.element, attr_object.class.try(:table_name)].compact
        names.find { |association_name| candidates.any? { |candidate| association_name.include?(candidate) } }
      end

      unless name
        raise ArgumentError,
              "Dynaspan could not find a nested association for #{attr_object.class.name} on #{klass.name}. " \
              "Add `accepts_nested_attributes_for` for it to #{klass.name}."
      end

      reflection = klass.try(:reflect_on_association, name)
      { name: name.to_sym, collection: reflection.respond_to?(:collection?) && reflection.collection? }
    end

    def dynaspan_unique_id(master_ds_object, attr_object, attrib)
      [dynaspan_record_id(master_ds_object), dynaspan_record_id(attr_object), attrib, SecureRandom.hex(3)]
        .join.gsub(/[^A-Za-z0-9_-]/, '_')
    end

    def dynaspan_record_id(record)
      record ? "#{record.class.name}#{record.try(:id)}" : ''
    end

    def dynaspan_form_options(custom)
      { method: :patch, authenticity_token: true }
        .merge((custom || {}).to_h.symbolize_keys)
        .tap do |form_options|
          form_options[:html] = (form_options[:html] || {}).to_h.symbolize_keys
          form_options[:html][:data] = { turbo: false }.merge((form_options[:html][:data] || {}).to_h.symbolize_keys)
        end
    end

    def dynaspan_html_options(custom, kind, unique_ref_id)
      html_options = (custom || {}).to_h.stringify_keys.except(*RESERVED_HTML_OPTIONS)
      html_options['class'] = [INPUT_CLASSES, html_options['class']].compact.join(' ').strip
      html_options['id'] = "dyna_span_field_val_#{unique_ref_id}"
      html_options['data'] = (html_options['data'] || {}).to_h.merge('dynaspan-input' => kind)
      html_options.symbolize_keys
    end

    def dynaspan_input(builder, kind, attrib, locals)
      case kind
      when :text_field then builder.text_field(attrib, locals[:html_options])
      when :text_area then builder.text_area(attrib, locals[:html_options])
      when :select
        builder.select(attrib, locals[:choices], locals[:select_options], locals[:html_options], &locals[:block])
      end
    end

    # Looks up the label shown for `value` among select choices. Supports the
    # formats Rails' `select` accepts: arrays, hashes, grouped choices and
    # pre-rendered option tags (e.g. from `options_for_select`).
    def dynaspan_choice_text(choices, value)
      return if choices.blank?

      target = value.to_s
      if choices.is_a?(String)
        require 'nokogiri'
        option = Nokogiri::HTML::DocumentFragment.parse(choices).css('option').find do |node|
          (node['value'] || node.text) == target
        end
        return option&.text
      end

      choices = choices.to_a if choices.is_a?(Hash)
      choices.each do |element|
        parts = element.is_a?(Array) ? element.reject { |part| part.is_a?(Hash) } : [element, element]
        label = parts.first
        option_value = parts.last

        if option_value.is_a?(Array) || option_value.is_a?(Hash)
          found = dynaspan_choice_text(option_value, value)
          return found if found
        elsif option_value.to_s == target
          return label.to_s
        end
      end
      nil
    end
  end
end
