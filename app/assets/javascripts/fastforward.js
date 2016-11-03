(function($){

  $.fn.fastForward = function(handler) {
    if (!this.length) {
      return;
    }
    var selected = this;
    $(document).keydown(function(event) {
      // Ctrl + Shift + F   ('F' has an ASCII keycode of 70)
      if (!event.ctrlKey || !event.shiftKey || event.keyCode !== 70) {
        return;
      }
      handler.call(selected);
    });
  };

})(jQuery);

$(function() {

  var FormFiller = function(form, formName) {
    this.hasDoneSomething = false;
    this.formName = formName;
    this.form = form;
  }

  // Click a radio button or checkbox if the value is not set yet.
  FormFiller.prototype.clickIfUnset = function(name, value) {
    if (this.form[this.formName + '[' + name + ']'].value) {
      return;
    }
    var control = $('#' + this.formName + '_' + name + '_' + value);
    if (!control.is(':enabled')) {
      return;
    }
    control.click();
    this.hasDoneSomething = true;
  };

  // Clicks true on a Yes/No radio button if the value is not set yet.
  FormFiller.prototype.clickTrueIfUnset = function(name) {
    this.clickIfUnset(name, 'true');
  };

  // Clicks a checkbox if none of the checkboxes of the group are set yet.
  FormFiller.prototype.clickIfAllUnset = function(name, value) {
    if ($('[id^=' + this.formName + '_' + name + '_]:checked').length) {
      return;
    }
    var control = $('#' + this.formName + '_' + name + '_' + value);
    if (!control.is(':enabled')) {
      return;
    }
    control.click();
    this.hasDoneSomething = true;
  };

  // Fills an input field if it's empty.
  FormFiller.prototype.fillIfUnset = function(name, value) {
    if (this.form[this.formName + '[' + name + ']'].value) {
      return;
    }
    var control = $('#' + this.formName + '_' + name);
    if (!control.is(':enabled')) {
      return;
    }
    control.val(value);
    this.hasDoneSomething = true;
  };

  $('#screenerForm').fastForward(function() {
    var form = new FormFiller(this[0], 'screener');
    form.clickTrueIfUnset('multiple_agencies');
    form.clickTrueIfUnset('shots_fired');
    form.clickTrueIfUnset('officer_used_force');
    form.clickTrueIfUnset('civilian_seriously_injured');
    form.clickTrueIfUnset('civilian_used_force');
    form.clickTrueIfUnset('officer_seriously_injured');
    if (!form.hasDoneSomething) {
      this.submit();
    }
  });

  $('.new_general_info, .edit_general_info').fastForward(function() {
    var form = new FormFiller(this[0], 'general_info');
    if (this[0]['general_info[incident_date_str]'].value === '  /  /    ') {
      // TODO: Make the date relative to current date.
      $('#general_info_incident_date_str').val('01/15/2016');
      form.hasDoneSomething = true;
    }
    form.fillIfUnset('incident_time_str', '1830');
    form.fillIfUnset('address', '1355 Market St');
    form.fillIfUnset('city', 'San Francisco');
    form.fillIfUnset('state', 'CA');
    form.fillIfUnset('zip_code', '94103');
    form.fillIfUnset('county', 'San Francisco County');
    form.fillIfUnset('num_involved_civilians', '1');
    form.fillIfUnset('num_involved_officers', '1');
    form.clickIfUnset('arrest_made', 'true');
    form.clickIfUnset('crime_report_filed', 'true');
    form.clickIfUnset('contact_reason', 'in_custody_event');
    form.clickIfUnset('in_custody_reason', 'out_to_court');
    if (!form.hasDoneSomething) {
      this.submit();
    }
  });

  $('.new_involved_civilian, .edit_involved_civilian').fastForward(function() {
    var form = new FormFiller(this[0], 'involved_civilian');
    form.clickTrueIfUnset('assaulted_officer');
    form.clickIfUnset('custody_status', 'deceased');
    form.clickTrueIfUnset('perceived_armed');
    form.clickIfAllUnset('perceived_armed_weapon', 'firearm');
    form.clickTrueIfUnset('confirmed_armed');
    form.clickIfAllUnset('confirmed_armed_weapon', 'firearm');
    form.clickIfAllUnset('firearm_type', 'rifle');
    form.clickTrueIfUnset('resisted');
    form.clickIfUnset('resistance_type', 'assaultive');
    form.clickTrueIfUnset('received_force');
    form.clickIfAllUnset('received_force_type', 'impact_projectile');
    form.clickIfAllUnset('received_force_location', 'rear_legs');
    form.clickIfAllUnset('mental_status', 'none');
    form.clickTrueIfUnset('injured');
    form.clickIfAllUnset('injury_type', 'abrasionlaceration');
    form.clickIfUnset('injury_level', 'death');
    form.clickIfUnset('medical_aid', 'medical_assistance_-_treated_on_scene');
    form.clickTrueIfUnset('injury_from_preexisting_condition');
    form.clickIfUnset('gender', 'female');
    form.clickIfAllUnset('race', 'hispanic');
    form.clickIfAllUnset('asian_race', 'hawaiian');
    if (!this[0]['involved_civilian[age]'].value) {
      $('#involved_civilian_age').val('41-45');
      form.hasDoneSomething = true;
    }
    if (!form.hasDoneSomething) {
      this.submit();
    }
  });

  $('.new_involved_officer, .edit_involved_officer').fastForward(function() {
    var form = new FormFiller(this[0], 'involved_officer');
    form.clickTrueIfUnset('officer_used_force');
    form.clickIfAllUnset('officer_used_force_reason', 'to_effect_arrest');
    form.clickTrueIfUnset('received_force');
    form.clickIfAllUnset('received_force_type', 'impact_projectile');
    form.clickIfAllUnset('received_force_location', 'armshands_');
    form.clickTrueIfUnset('injured');
    form.clickIfUnset('injury_level', 'injury');
    form.clickIfAllUnset('injury_type', 'unconscious');
    form.clickIfUnset('medical_aid', 'no_medical_assistance_or_refused_assistance');
    form.clickTrueIfUnset('injury_from_preexisting_condition');
    form.clickIfUnset('gender', 'female');
    if (!this[0]['involved_officer[age]'].value) {
      $('#involved_officer_age').val('36-40');
      form.hasDoneSomething = true;
    }
    form.clickIfAllUnset('race', 'asian_indian');
    form.clickIfAllUnset('asian_race', 'cambodian');
    form.clickTrueIfUnset('on_duty');
    form.clickIfUnset('dress', 'patrol_uniform');
    if (!form.hasDoneSomething) {
      this.submit();
    }
  });

  $('#incidentStep.review').fastForward(function() {
    $('button[type=submit]').click();
  });
});
