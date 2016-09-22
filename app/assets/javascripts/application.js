// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// *******************************************
// * MANIFEST
// *******************************************
//= require es5-shim/es5-shim
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery-ui
//= require jquery-ui/datepicker
//= require jquery-ui-timepicker-addon
//= require_directory .
//= require_directory ./lib
//= stub fastforward
//= require geocomplete
//= require Chart.bundle
//= require chartkick
//= require ahoy

$(function() {
  // General initialization code that applies to all pages goes here.
  $('[data-toggle="popover"]').popover({container: "body", html: true});
});
