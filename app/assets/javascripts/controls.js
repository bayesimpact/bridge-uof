function positionControls() {
  // Set margin-top of #controls based on what is above them.

  $('#controls').css('margin-top', '0px');

  if ($('#breadcrumbs').is(':visible')) {
    $('#controls').css('margin-top', parseInt($('#controls').css('margin-top')) + $('#breadcrumbs').outerHeight() + 'px');
  }

  if ($('#demoWarning').is(':visible')) {
    $('#controls').css('margin-top', parseInt($('#controls').css('margin-top')) + $('#demoWarning').outerHeight() + 'px');
  }

  // Enable StickyKit.

  if (navigator.userAgent.indexOf("PhantomJS") == -1) {
    // The StickyKit plugin causes bizarre MouseEventFailed errors in our Poltergeist tests,
    // so we just disable it if we detect that we're inside PhantomJS.
    var offset = parseInt($('#controls').css('margin-top'));
    $('#controls').stick_in_parent({bottoming: false, offset_top: -offset});
  }
}

function setZoomLevel(zoomLevel) {
  // See http://stackoverflow.com/a/9441618
  sessionStorage['zoomLevel'] = zoomLevel;
  $('body').css('zoom', (zoomLevel * 100) + "%");
  $('body').css('-moz-transform', "scale(" + zoomLevel + ")");
  $('body').css('-moz-transform-origin', "0 0");
}

function adjustZoom(delta) {
  var currentZoom = parseFloat(sessionStorage['zoomLevel']) || 1.0;
  setZoomLevel(currentZoom + delta);
}

$(function() {
  positionControls();
  $(window).resize(positionControls);

  if (sessionStorage['zoomLevel']) {
    setZoomLevel(parseFloat(sessionStorage['zoomLevel']));
  }

  $("#zoomIn").click(function () { adjustZoom(0.1); });
  $("#zoomReset").click(function () { setZoomLevel(1.0); });
  $("#zoomOut").click(function () { adjustZoom(-0.1); });
  $("#print").click(function () { window.print(); });
});
