$(document).ready(function() {
  $('form#user-sign-in').on('ajax:success', function(e, data, status, xhr) {
    if(data.success)
      window.location.reload();
  })
});