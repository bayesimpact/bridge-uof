$(function(){
  togglePreExistingCondition()
  medicalAid()

  function enableDisableSubQuestion(state) {
    // For 'on' callback function, the parameters are stored under data.
    state = state.data || state;

    selection = $(state.triggerSelection);
    if (selection.length == 0) {
      return;
    }

    // TODO: For-real js tests for this behavior, it's a bit hairy.
    if ($(state.triggerSelection + ":checked").val() && !selection.prop('disabled')) {
      enableQuestions(state.additionalQuestion);
    } else {
      disableQuestions(state.additionalQuestion);
    }
  }

  // Some questions need only be displayed
  var subQuestionTriggers = [
    ['screener[shots_fired]', '#screener_shots_fired_false', '#officer-used-force'],
    ['screener[shots_fired]', '#screener_shots_fired_false', '#civilian-used-force'],
    ['screener[officer_used_force]', '#screener_officer_used_force_true', '#civilian_injured'],
    ['screener[civilian_used_force]', '#screener_civilian_used_force_true', '#officer_injured'],
    ['general_info[contact_reason]', '#general_info_contact_reason_in_custody_event', '#custody_event_option'],
    ['involved_civilian[perceived_armed]', '#involved_civilian_perceived_armed_true', '#perceived_armed_weapon_question'],
    ['involved_civilian[confirmed_armed]', '#involved_civilian_confirmed_armed_true', '#confirmed_armed_weapon_question'],
    ['involved_civilian[confirmed_armed_weapon][]', '#involved_civilian_confirmed_armed_weapon_firearm', '#firearm_type_question'],
    ['involved_civilian[resisted]', '#involved_civilian_resisted_true', '#resistance_type_question'],
    ['involved_civilian[received_force]', '#involved_civilian_received_force_true', '#received_force_type_question'],
    ['involved_civilian[injured]', '#involved_civilian_injured_true', '#injury_additional_questions'],
    ['involved_civilian[race][]', '#involved_civilian_race_asian__pacific_islander', '#asian-races'],
    ['involved_officer[received_force]', '#involved_officer_received_force_true', '#received_force_type_question'],
    ['involved_officer[officer_used_force]', '#involved_officer_officer_used_force_true', '#used_force_reason_question'],
    ['involved_officer[injured]', '#involved_officer_injured_true', '#injury_additional_questions'],
    ['involved_officer[race][]', '#involved_officer_race_asian__pacific_islander', '#asian-races']
  ];
  $.each(subQuestionTriggers, function(idx, values) {
    var state = {triggerSelection: values[1], additionalQuestion: values[2]};
    var inputName = 'input[name="' + values[0] + '"]';
    $(inputName).on('change', state, enableDisableSubQuestion);
    $(inputName).trigger('change');
  });

  // For civilians that fled the scene, certain fields we will not collect
  // as the officer cannot be sure of what they saw of the person.
  $('input[name="involved_civilian[custody_status]"]').on('change', function() {
    // We only need to enable/disable parent questions. This will trigger a
    // change event and automatically handle subquestions correctly.
    div_ids = ['injured_question', 'age_question', 'sex_question',
               'race_question', 'confirmed_armed_question'];
    fled_info_text_div_id = 'fled-info-text'
    if ($('#involved_civilian_custody_status_fled').is(':checked')) {
      $.each(div_ids, function(idx, elt_it) {
        disableQuestions('#' + elt_it);
      });
      $('#' + fled_info_text_div_id).show();
    } else {
      $.each(div_ids, function(idx, elt_it) {
        enableQuestions('#' + elt_it);
      });
      $('#' + fled_info_text_div_id).hide();
    }
    // Highest charge is also not needed if the suspect is deceased.
    if ($('#involved_civilian_custody_status_cited_and_released').is(':checked') ||
        $('#involved_civilian_custody_status_in_custody_other').is(':checked')) {
      enableQuestions('#charge_questions');
    } else {
      disableQuestions('#charge_questions');
    }
  }).trigger('change');

  // Display screener info text when necessary.
  $('#screenerForm input').on('change', function () {
    $('#multiple-agencies-info-text').toggle($('#screener_multiple_agencies_true').is(':checked'));
    $('#shots-fired-info-text').toggle($('#screener_shots_fired_true').is(':checked'));
  }).change();


  function medicalAid() {
    $('.medical-aid-received input[type="radio"]').on('click', function () {
      togglePreExistingCondition()
    })
  }

  function togglePreExistingCondition() {
    if ($('input[value="No medical assistance or refused assistance"]').is(':checked')) {
      $('.additional-question.pre-existing-condition').hide()
    } else {
      $('.additional-question.pre-existing-condition').show()
    }
  }
});
