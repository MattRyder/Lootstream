$(document).on('ready page:ready', function() {

  $('.sidebar-game-item').on('click', function(e) {
    e.preventDefault();
    $.ajax({
      url: "/channels/game_search.js",
      type: 'POST',
      data: { "game_name" : e.target.text }
    }).complete(function(data) {
      eval(data.responseText);
    });
  });
});