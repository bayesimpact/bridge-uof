$(function(){
  $("#general_info_address").geocomplete({
    // Restrict to US.
    country: 'US',
    // Give a preference to California.
    // Coordinates rounded from https://en.wikipedia.org/wiki/California.
    bounds: {
      south: 32.53,
      north: 42,
      west: -124.43,
      east: -114.13
    }
  }).bind("geocode:result", function(event, result) {
      $("#general_info_address").val(result.name);
      $.map(result.address_components, function (c) {
        if (c.types.indexOf("locality") > -1) {
          $("#general_info_city").val(c.long_name);
        }
        if (c.types.indexOf("administrative_area_level_2") > -1) {
          $("#general_info_county").val(c.long_name);
        }
        if (c.types.indexOf("administrative_area_level_1") > -1) {
          $("#general_info_state").val(c.short_name);
        }
        if (c.types.indexOf("postal_code") > -1) {
          $("#general_info_zip_code").val(c.long_name);
        }
      });
    });
});
