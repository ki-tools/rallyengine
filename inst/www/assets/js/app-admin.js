var decorate_error = function(a) {
  var error = new RegExp('^Error');
  a = a.map(function(d) {
    if (error.test(d)) {
      return "<span class='error'>" + d + '</span>';
    } else {
      return d;
    }
  });
  return a;
}

$(document).ready(function(){
  SERVER = window.RALLY_API_SERVER;

  $('#parse-button').click(function() {
    $('#parse-button').addClass('disabled');
    $('#ppt-button').addClass('disabled');
    $('#status').removeClass('hidden');
    $("#status").html('')
    $.getJSON(SERVER + '/update', function(id) {
      out = [];
      function status_loop() {
        $.getJSON(SERVER + '/check_update?id=' + id, function(data) {
          out = data;
        })
        setTimeout(function() {
          if (out[out.length - 1] === "FINISHED") {
            $('#parse-button').removeClass('disabled');
            $('#ppt-button').removeClass('disabled');
          } else {
            status_loop();
          }
          out = decorate_error(out);
          var txt = anchorme(out.join("<br>"), { attributes: [{ name: "target", value: "blank"}]});
          $('#status').html(txt);
        }, 300);
      };
      status_loop();
    })
    .done(function() {
      console.log('parse update initiated...');
    })
    .fail( function(d, textStatus, error) {
      console.error('getJSON failed, status: ' + textStatus + ', error: ' + error)
    });
  });

  $('#ppt-button').click(function() {
    $('#parse-button').addClass('disabled');
    $('#ppt-button').addClass('disabled');
    $('#status').removeClass('hidden');
    $("#status").html('')
    $.getJSON(SERVER + '/update_ppt', function(id) {
      out = [];
      function status_loop() {
        $.getJSON(SERVER + '/check_update_ppt?id=' + id, function(data) {
          out = data;
        })
        setTimeout(function() {
          if (out[out.length - 1] === "FINISHED") {
            $('#parse-button').removeClass('disabled');
            $('#ppt-button').removeClass('disabled');
          } else {
            status_loop();
          }
          out = decorate_error(out);
          var txt = anchorme(out.join("<br>"), { attributes: [{ name: "target", value: "blank"}]});
          $('#status').html(txt);
        }, 300);
      };
      status_loop();
    })
    .done(function() {
      console.log('ppt update initiated...');
    })
    .fail( function(d, textStatus, error) {
      console.error('getJSON failed, status: ' + textStatus + ', error: ' + error)
    });
  });
});
