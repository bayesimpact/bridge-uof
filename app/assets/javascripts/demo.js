$(function(){
  // #hideDemoWarning button immediately hides the demo warning and sets a cookie.
  $('#hideDemoWarning').click(function () {
    $('#demoWarning').hide();
    positionControls();  // (see controls.js)

    document.cookie = 'hide_demo_msg=true';
  });
  $('#generateFakeIncidentsButton').click(function (event) {
    $("#dashboardColumn div.alert").css("opacity", "0.5");
    $(this).val("Generating....").prop("disabled", true);
    $(this).parents('form').submit();
  });
});
