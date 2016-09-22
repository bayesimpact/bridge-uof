/* IE<=8-specific JS hacks. */

$(function () {
  // Hide #breadcrumbs-ursus-id because for some reason it makes the page not load.
  $('#breadcrumbs-ursus-id').hide();

  // Analytics don't work for a few reasons. Just don't display them.
  $('.visualization').text(
    "Your web browser, Internet Explorer 8, does not support this chart. " +
    "If you'd like to see this visualization, try any newer version of Internet Explorer (9, 10, etc) " +
    "or another major browser (Chrome, Firefox, etc)."
  );

  // Call positionControls() (event handler on window resize) a little later to make
  // it correctly calculate the top margin of #controls. [see controls.js].
  setTimeout(function () {
    $(window).resize();
  }, 1000);
});
