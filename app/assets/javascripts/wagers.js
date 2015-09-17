$(document).ready(function() {

  $(".option").click(function(e) {
    e.preventDefault();
    var element = $(this), amount_data = $('#amount').val(),
        amount_val = parseFloat(amount_data);

    if(isNaN(amount_val) || amount_val <= 0) {
      return false;
    }

    $.ajax({
      type: 'POST',
      url: '/place_bet',
      dataType: 'json',
      data: { amount: amount_data, wager_option_id: this.name },
      success: function(data) {
        if(data.success) {
          $('#stream-balance a').html("Stream Balance: $"+data.new_balance);
          element.parent().addClass('btn-success');
          $('.btn').attr('disabled', 'disabled');
          $('input').attr('disabled', 'disabled');
        } else {
          $('#amount').parent().addClass('has-error');
          $('.input-group #amount').val("").attr('placeholder', data.error_message);
        }
        return false;
      },
      error: function(data) {
        return false;
      }
    });
  });
});