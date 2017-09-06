$(document).ready(function(){
  SERVER = window.RALLY_API_SERVER;

  $('#parse-button').click(function() {
    $('#parse-button').addClass('disabled');
    $('#status').removeClass('hidden');
    $("#status").html('')
    $.getJSON(SERVER + '/update', function(id) {
      out = [];
      function status_loop() {
        $.getJSON(SERVER + '/check_update?id=' + id, function(data) {
          out = data;
        })
        setTimeout(function() {
          if (out[out.length - 1] !== "FINISHED") {
            status_loop();
          }
          $('#status').html(out.join('<br>'))
        }, 300);
      };
      status_loop();
      $('#parse-button').removeClass('disabled');
    })
    .done(function() {
      console.log('parse update initiated...');
    })
    .fail( function(d, textStatus, error) {
      console.error('getJSON failed, status: ' + textStatus + ', error: ' + error)
    });
  })
});
