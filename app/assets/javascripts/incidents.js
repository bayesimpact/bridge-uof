// Note: To keep this file as small and straightforward as possible, put
// reusable helper methods in util.js and moderately-sized self-contained
// components into incidents.*.js files (e.g. incidents.address.js).
$(function(){
  $("#dashboardSideNav li").on('click', function(e) {
    window.location.href = $(this).find("a").attr('href');
  });

  $('#screener_ori').change(function () {
    if ($('#screener_ori').val() == $('#screener_ori option:first').val()) {
      $('#filling-out-for').hide();
    } else {
      $('#filling-out-for-ori').text($('#screener_ori').val());
      $('#filling-out-for').show();
    }
  }).change();

  // Add datetime formatter for event date.
  $('#general_info_incident_date_str').formatter({
    'pattern': '{{99}}/{{99}}/{{9999}}',
    'persistent': true
  });

  $('#showHideAuditLog').toggleLinkFor($('#auditLog'));

  $('#upload-control input[type=file]').change(function () {
    $('#upload-control').submit();
  });

  // Partial save link disables validation and triggers form submit.
  $('#save_and_return').click(function (e) {
    e.preventDefault();
    $('#validate_and_continue').val("false");
    $("[type=submit]").click();
  });


  // For the erratic behavior question, uncheck other options when
  // the 'None of these' choice is selected, and uncheck 'None of these'
  // when another choice is selected.
  $('input[name="involved_civilian[mental_status][]"]').on('change', function() {
    if ($(this).attr('value') == 'None') {
      $('input[name="involved_civilian[mental_status][]"]').filter(function() {
        return ($(this).attr('value') != 'None')
      }).attr('checked', false);
    } else {
      $('#involved_civilian_mental_status_none').attr('checked', false);
    }
  });
});
