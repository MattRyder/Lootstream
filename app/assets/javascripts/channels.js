$(document).ready(function() {
  $('.sidebar-game-item').on('click', function(e) {
    e.preventDefault();
    renderGameSearch(e.target.text);
  });

  $(".game-search").on("keydown", function(e) {
    if(e.which != 13)
      return;

    e.preventDefault();
    renderGameSearch($(this).val());
    $(this).val("");
  });

  $(document).on('page:before-change', function() {
    if(window["wagerPollInterval"] !== undefined)
      window.clearInterval(wagerPollInterval);

    if(window["wagerUpdateInterval"] !== undefined)
      window.clearInterval(wagerUpdateInterval);
  })
});

var renderGameSearch = function(gameName) {
  $.ajax({
    url: "/channels/game_search.js",
    data: { "game_name" : gameName }
  }).complete(function(data) {
    if(!!data.responseText.trim()) {
      $(".game-search").attr('placeholder', 'Search');
      eval(data.responseText);
      $("#search-title").text("Results for: "+gameName);
    } else {
      $(".game-search").attr('placeholder', 'No Streams Found!');
    }
  });
};

var initIntervals = function(wagerId, userId, chanSlug) {
  if(window.location.pathname.match(/\/channels\/[A-z0-9_]+/)) {
    window["wagerPollInterval"] = setInterval(function() {
      wagerStatisticsUpdate(chanSlug, wagerId, userId);
    }, 5000);
  }
};

// AJAX Update the current wager if Streamer changes it:
// Updates the wager odds etc
var wagerStatisticsUpdate = function(channelSlug, wagerId, userId) {
  if(!channelSlug)
    return;

  // TODO: Replace with one AJAX call:
  $.ajax({
    url: "/channels/"+channelSlug+"/active.js",
    data: { "current_wager": $('.wager').data('wid') }
  }).success(function(data) {
    eval(data.responseText);
  });

  $.ajax({
    url: '/channels/'+channelSlug+'/wagers/'+wagerId+'/realtime',
    dataType: 'JSON',
    data: { uid : userId }
  }).success(function(data) {
    if(data.odds) {
      for(var i = 0; i < data.odds.length; i++) {
        var lbl = $(".option-"+data.odds[i].id).find('.label');
        if(lbl) { lbl.html(data.odds[i].value); }
      }
    }
    if(data.wager_state) {
      $('#stream-balance a').html("Stream Balance: $"+data.wager_state.balance);
      $('.wager .title').text("You "+data.wager_state.state+"!");
      $('.wager .btn').parent().not('.option-'+data.wager_state.winopt).hide();
      $('.wager .btn').parent('.option-'+data.wager_state.winopt).addClass('col-xs-12');
      if(window.wagerPollInterval) {
        window.clearInterval(wagerPollInterval);
      }
    }
  });
};