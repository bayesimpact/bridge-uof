function pad(str, n) {
  // e.g. pad("blah", 6) = "blah  "
  return (str + "                              ").slice(0, n);
}

function disableQuestions(selector) {
  $(selector).addClass("disabled");
  $(selector + " input").prop("disabled", true);
  $(selector + " select").prop("disabled", true);
  // Trigger change event to notify any sub-questions.
  $(selector + " input").trigger('change');
  $(selector + " select").trigger('change');
}

function enableQuestions(selector) {
  $(selector).removeClass("disabled");
  $(selector + " input").prop('disabled', false);
  $(selector + " select").prop('disabled', false);
  // Trigger change event to notify any sub-questions.
  $(selector + " input").trigger('change');
  $(selector + " select").trigger('change');
}

$.fn.extend({
  toggleLinkFor: function (toggleable) {
    $(this).click(function () {
      toggleable.toggle();
      $(this).text(toggleable.is(':visible') ? '[hide]' : '[show]');
    });
  }
});