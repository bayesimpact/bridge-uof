var unsavedChanges = false;

$(function () {
  $('#incidentStep').on('change keyup keydown', 'input, textarea, select', function (e) {
      unsavedChanges = true;
  });

  $(document).submit(function() {
      unsavedChanges = false;
  });

  $(window).on('beforeunload', function () {
    if (unsavedChanges) {
      return 'You have unsaved changes.';
    }
  });
});