$(function(){
  // Add autocomplete for agency ori search bar
  $('#doj_incidents_ori_box').autocomplete({
    source: window.AGENCY_ORI,
    select: function (event, ui) {
      window.location.href = '/doj/incidents/' + ui.item.label;
    }
  });
});
