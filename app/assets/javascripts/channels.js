$(document).on('ready page:ready', function() {

  var renderGameSearch = function(gameName) {
    $.ajax({
      url: "/channels/game_search.js",
      type: 'POST',
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
  }

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

  // AJAX Update the current wager if Streamer changes it:
  var wagerUpdate = function(channelSlug, wagerId, userId) {
    if(!channel_slug)
      return;

    $.ajax({
      url: "/channels/"+channelSlug+"/active.js",
      data: { "current_wager": $('.wager').data('wid') }
    }).complete(function(data) {
      eval(data.responseText);
      if (!!data.responseText.trim()) {
        wagerPollInterval = setInterval(w, 3000);
      }
    });
  };

  // Updates the wager odds etc
  var wagerStatisticsUpdate = function(wagerId, userId) {
    $.ajax({
      url: '/wagers/'+wagerId+'/realtime',
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
        $('.wager .title').text("You "+data.wager_state.state+"!");
        $('.wager .btn').parent().not('.option-'+data.wager_state.winopt).hide();
        $('.wager .btn').parent('.option-'+data.wager_state.winopt).addClass('col-xs-12');
        if(window.wagerPollInterval) {
          window.clearInterval(wagerPollInterval);
        }
      }
    });
  };

  $(document).on('page:before-change', function() {
    window.clearInterval(wagerPollInterval);
    window.clearInterval(wagerUpdateInterval);
  })

  var initIntervals = function(wagerId, userID, chanSlug) {
    if(window.location.pathname.match(/\/channels\/[A-z0-9_]+/)) {
      // Hahahahaha, What the actual fuck am I doing here?
      // TODO: Figure out a better way, than throwing everything to wagerUpdate()!!
      var wagerPollInterval = setInterval(wagerStatisticsUpdate(wagerId, userId), 3000);
      var wagerUpdateInterval = setInterval(wagerUpdate(chanSlug, wagerId, userId), 5000);
    }
  };
});