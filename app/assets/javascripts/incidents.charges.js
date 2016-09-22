$(function(){
  function formatCrime(crimeText) {
    // Parse (MISDEMEANOR) and (FELONY)
    var isMisdemeanor = crimeText.indexOf("(MISDEMEANOR)") > -1;
    var isFelony = crimeText.indexOf("(FELONY)") > -1;
    var type = isMisdemeanor ? "M" : (isFelony ? "F" : " ");
    crimeText = crimeText.replace(" (MISDEMEANOR)", "").replace(" (FELONY)", "");

    if (isNaN(crimeText.split(" ")[1][0])) {
      // first char of second group is NOT a number: e.g.
      //    148(A)(1) PC OBSTRUCT/ETC PUB OFCR/ETC (MISDEMEANOR)
      var num = crimeText.split(" ")[0];
      var code = crimeText.split(" ")[1];
      var text = crimeText.split(" ").slice(2).join(" ");
    } else {
      // first char of second group IS a number: e.g.
      //    18 3148(A) US VIOL CONDITION OF RELEASE (FELONY)
      var num = crimeText.split(" ").slice(0, 2).join(" ");
      var code = crimeText.split(" ")[2];
      var text = crimeText.split(" ").slice(3).join(" ");
    }

    return pad(num, 17) + " " + pad(code, 6) + " " + pad(text, 30) + " " + type;
  }

  // Add autocomplete for crime codes.
  $('#involved_civilian_highest_charge').autocomplete({
    source: $.map(window.CRIMES, function (c) { return {'value': c, 'label': formatCrime(c)}; })
  });
  // Add a CSS class to the autocomplete widget so that we can style it individually.
  $('#involved_civilian_highest_charge').autocomplete('widget').addClass('charge-dropdown');

  // Add autocomplete for crime qualifier codes.
  $('#involved_civilian_crime_qualifier').autocomplete({
    source: $.map(window.CRIME_QUALIFIERS, function (c) { return {'value': c, 'label': formatCrime(c)}; })
  });
  // Add a CSS class to the autocomplete widget so that we can style it individually.
  $('#involved_civilian_crime_qualifier').autocomplete('widget').addClass('charge-dropdown');
});
