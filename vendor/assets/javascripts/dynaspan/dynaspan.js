// MIT LICENSE
// Copyright (c) 2014 Daniel P. Clark
(function($){
  $.fn.dynaspan = function(){};

  $.fn.dynaspan.appendParameter = function(excmd,append_param){
    var regExp = [/\(([^)]+)\);?$/,/\(\);?$/];
    var matches = [regExp[0].exec(excmd), regExp[1].exec(excmd)];
    if (matches[0]){
      return(excmd.replace(matches[0][0],'(' + matches[0][1] + ',' + append_param +');'));
    } else if (matches[1]) {
      return(excmd.replace(matches[1][0],'(' + append_param + ');'));
    } else {
      return excmd.replace(/;$/,'') + '(' + append_param + ');';
    }
  };

  $.fn.dynaspan.upLast = function(uniq_id_ref){
    $('#dyna_span_field_val_' + uniq_id_ref).val($('#last_dyna_span_val_' + uniq_id_ref).val());
  };

  $.fn.dynaspan.upShow = function(uniq_id_ref){
    $('#dyna_span_div' + uniq_id_ref).show().find('.dyna-span-input').focus();
    $('#dyna_span_span' + uniq_id_ref).hide();
    $("#dyna_span_block" + uniq_id_ref).addClass("ds-dialog-open");
  };

  $.fn.dynaspan.upHide = function(uniq_id_ref){
    var field_val = $('#dyna_span_field_val_' + uniq_id_ref).val();
    $('#dyna_span_div' + uniq_id_ref + ' > form').trigger('submit.rails');
    $('#last_dyna_span_val_' + uniq_id_ref).val(field_val);
    $('select#dyna_span_field_val_' + uniq_id_ref).each(function(){
      field_val = $(this).children("option:selected").text()
    });
    $('#dyna_span_span' + uniq_id_ref).show().html(field_val);
    $('#dyna_span_div' + uniq_id_ref).hide();
    var ds_block = $("#dyna_span_block" + uniq_id_ref);
    ds_block.removeClass("ds-dialog-open");
    if (field_val.length == 0){
      ds_block.removeClass("ds-content-present")
    } else {
      ds_block.addClass("ds-content-present")
    }
    if (ds_block.data('dsCallbackWithValues')){
      eval(
        $.fn.dynaspan.appendParameter(
          ds_block.data('dsCallbackWithValues'),
          "{ds_selector:'#dyna_span_block" + uniq_id_ref + "',ds_input:'" + field_val + "'}"
        )
      )
    }
    if (ds_block.data('dsCallbackOnUpdate')){
      eval(ds_block.data('dsCallbackOnUpdate'))
    }
  };
})(jQuery);
