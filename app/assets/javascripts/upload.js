$(function(){
  $('#showHideSchema').toggleLinkFor($('#schema'));

  $('#xmlSchema').hide();
  $('.toggle-schema').click(function () {
    $('#jsonSchema').toggle();
    $('#xmlSchema').toggle();
  });

  $('#upload-control').submit(function (event) {
    var fileButton = $(".btn-file");
    $('.btn-file').css({'opacity': 0.5, 'background-color': 'gray'});
    $("#fileButtonText").html("Uploading....");
  });
});
