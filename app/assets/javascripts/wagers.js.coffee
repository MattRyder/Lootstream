# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.option').click ->
    element = $(this)
    amount_data = $('#amount').val()
    console.log("Betting $"+amount_data+" on "+element.text())
    $.ajax({
      type: 'POST',
      url: '/place_bet',
      dataType: 'json'
      data: { amount: amount_data, wager_option_id: this.name },
      success: (data) ->
        if data.success
          $('#stream-balance a').html("Stream Balance: $"+data.new_balance)
          element.parent().addClass('btn-success')
          $('.btn').attr('disabled', 'disabled');
          $('input').attr('disabled', 'disabled');
        else
          $('#amount').parent().addClass('has-error')
          $('.input-group #amount').val("").attr('placeholder', data.error_message)
        return false
      error: (data) ->
        console.log(data)
        return false
    })