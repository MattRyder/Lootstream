$(document).on("ready page:load", function() {

  $(".option").click(function() {
    var element = $(this), amount_data = $('#amount').val();
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

  $("#submit-type").on("click", function(e) {
    e.preventDefault();
    $.ajax({
      url: '/wagers/render_form.js',
      data: { "game_id" : $("#wager_game_id").val() },
      beforeSend: function(xhr, settings) {
        $("#wager_game_id").attr("disabled", true);
      }
    }).success(function(data) {
      eval(data);
      $("#game-infographic").hide();
      $("#game-description").hide();
      $("#submit-type").hide();

    });
  });

});