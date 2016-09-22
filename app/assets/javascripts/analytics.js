$(function(){
  // Selecting a new year automatically redirects to that page.
  $('#analytics-year').change(function () {
    window.location.href = $(this).val();
  });
});

function renderPivotTable(year) {
  var jsonPath = year ? "/incidents.json?year=" + year : "/incidents.json";
  $.getJSON(jsonPath, function(data) {
    $("#pivot-table").pivotUI(data, {
      rows: ["Officer Force Used"],
      cols: ["Civilian Armed?"],
      rendererName: "Table"
    });
  });
}
