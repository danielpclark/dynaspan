module Dynaspan
  module ApplicationHelper

    def dynaspan_text_field(master_ds_object,*parameters)
      dynaspan_text('field', master_ds_object, parameters)
    end

    def dynaspan_text_area(master_ds_object,*parameters)
      dynaspan_text('area', master_ds_object, parameters)
    end

    private

    def dynaspan_counter
      @count_for_viewspace = @count_for_viewspace.to_i + 1
    end

    def dynaspan_text(kind, master_ds_object,*parameters)
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
      render(
          partial: "dynaspan/dynaspan_text_#{kind}",
          locals: {
            master_ds_object: master_ds_object,
            attr_object: attr_object,
            attrib: attrib,
            unique_ref_id: options.fetch(:unique_id) { dynaspan_counter },
            dyna_span_edit_text: edit_text,
            hidden_fields: options[:hidden_fields],
            ds_callback_on_update: options[:callback_on_update],
            ds_callback_with_values: options[:callback_with_values],
            form_for_options: options[:form_for]
          }
      )
    end
  end
end
