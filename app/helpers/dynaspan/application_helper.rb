module Dynaspan
  module ApplicationHelper

    def dynaspan_text_field(master_ds_object,*parameters)
      dynaspan_text('field', master_ds_object, parameters)
    end

    def dynaspan_text_area(master_ds_object,*parameters)
      dynaspan_text('area', master_ds_object, parameters)
    end

    def dynaspan_select(master_ds_object,*parameters, &block)
      dynaspan_text('select', master_ds_object, parameters, &block)
    end

    private
    module_function

    def to_id(obj)
      !!obj ? "#{obj.class.name}#{obj.try(:id)}" : ""
    end

    def dynaspan_text(kind, master_ds_object,*parameters, &block)
      parameters.flatten!
      if parameters.first.is_a? Symbol
        attr_object = nil
        attrib = parameters.first
        edit_text = parameters.try(:[],1)
      elsif parameters[1].is_a? Symbol
        attr_object, attrib = parameters
        edit_text = parameters.try(:[],2)
      else
        raise 'You did not provide a symbol for the form field.'
      end
      edit_text = nil unless edit_text.is_a? String
      options = ActiveSupport::HashWithIndifferentAccess.new(parameters[-1].is_a?(Hash) ? parameters[-1] : {})
      options.default = nil
      options[:form_for] = ActiveSupport::HashWithIndifferentAccess.new(options[:form_for])
      options[:form_for].reverse_merge!(
        method: :patch,
        remote: true,
        authenticity_token: true
      )
      options[:html_options] = ActiveSupport::HashWithIndifferentAccess.new(options[:html_options])
      options[:html_options][:class] = "dyna-span form-control dyna-span-input #{options[:html_options][:class]}"
      options[:html_options].delete_if {|k,v| [:id, :onblur, :onfocus].include? k}
      render(
          partial: "dynaspan/dynaspan_text_#{kind}",
          locals: {
            master_ds_object: master_ds_object,
            attr_object: attr_object,
            attrib: attrib,
            unique_ref_id: options.fetch(:unique_id) { [to_id(master_ds_object), to_id(attr_object), attrib].join },
            dyna_span_edit_text: edit_text,
            hidden_fields: options[:hidden_fields],
            ds_callback_on_update: options[:callback_on_update],
            ds_callback_with_values: options[:callback_with_values],
            form_for_options: options[:form_for],
            schoices: options[:choices],          # For form 'select' field
            soptions: options.fetch(:options) { Hash.new },          # For form 'select' field
            html_options: options[:html_options],
            block: block
          }
      )
    end
  end
end
