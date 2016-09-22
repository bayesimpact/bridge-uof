$(function() {
  var SEPARATOR = ' -> ';

  function refreshSortableEntries(steps) {
    $('.order-of-force')
      .empty()
      .append($.map(steps, function (s) {
        return $('<li class="alert alert-info"></li>').
          append('<span class="order"></span>').
          append($('<span class="value"></span>').text(s));
      }));
    renumber();

    // Only enable the checkbox iff there are >= 2 entries
    if (steps.length >= 2) {
      enableQuestions('#order-of-force-section');
    } else {
      disableQuestions('#order-of-force-section');
      $('#order-of-force-specified').prop('checked', false);
    }
  }

  function renumber() {
    $('.order-of-force li .order').each(function(i, span) {
      $(span).text((i + 1) + '. ');
    });
  }

  function updateHiddenField() {
    renumber();
    if ($('.order-of-force').sortable('option', 'disabled')) {
      $('#order-of-force-str').val('');
    } else {
      var order = $('.order-of-force li .value').map(function () { return $(this).text(); }).toArray();
      $('#order-of-force-str').val(order.join(SEPARATOR));
    }
  }

  function loadFromHiddenField() {
    if ($('#order-of-force-str').val() !== '') {
      var order = $('#order-of-force-str').val().split(SEPARATOR);
      refreshSortableEntries(order);
    } else {
      // Hidden field not set, so initialize the sortable area based on the input fields.
      $('.type-of-force input').change();
      $('#order-of-force-specified').change();
    }
  }

  $('#order-of-force-specified').change(function () {
    $('.order-of-force').sortable($('#order-of-force-specified').is(':checked') ? 'enable' : 'disable');
    updateHiddenField();
  });

  $('.type-of-force input').change(function () {
    var forceOrder = [];
    if ($('#order-of-force-specified').is(':checked')) {
      forceOrder = $('#order-of-force-str').val().split(SEPARATOR);
    }
    var checkedItems = $('.type-of-force input:checked').map(function () {return $(this).val(); });
    // To preserve the order, we:
    // 1. Remove any items in the old order that are not in the new item set
    // 2. Add any new items to the end of the current order
    for (var i=forceOrder.length - 1; i >= 0; --i) {
      if ($.inArray(forceOrder[i], checkedItems) == -1) {
        forceOrder.splice(i, 1);
      }
    }
    $.each(checkedItems, function(idx, item){
      if ($.inArray(item, forceOrder) == -1) {
        forceOrder.push(item);
      }
    });
    refreshSortableEntries(forceOrder);
    updateHiddenField();
  });

  $('.order-of-force').sortable({
    create: loadFromHiddenField,
    stop: updateHiddenField
  });
});
