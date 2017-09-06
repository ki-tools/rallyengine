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

  // $.getJSON('question_data.json', function(data) {
  // $.getJSON('http://localhost:8000/questions', function(data) {

  //   var nq = 0;
  //   data.map(function(d) { if (d.rally_link !== undefined) { nq++;} })

  //   $('#title').html(data.length + ' Prioritized Questions with ' + nq + ' Addressed by Rallies To Date');

  //   var template = $('#template').html();
  //   Mustache.parse(template);   // optional, speeds up future uses
  //   var rendered = Mustache.render(template, data);
  //   $('#question-data').html(rendered);

  //   var table = $('#questions').DataTable({
  //     "fixedHeader": true,
  //     "paging": false,
  //     "order": [[ 2, "desc" ]],
  //     "language": {
  //       "info": "",
  //       "infoEmpty": "",
  //       "infoFiltered":   "Showing _TOTAL_ of _MAX_ questions"
  //     },
  //     "mark": true,
  //     "rowCallback": function(row, data, index) {
  //       // set the tooltip value
  //       var el = $('td.hbgd-cat > span', row);
  //       el.attr("data-tooltip", q5[el.text().trim()]);

  //       var nd = $('td.rally-status', row).attr("data-end");
  //       if (nd !== '') {
  //         var dt = new Date(nd);
  //         if (dt > new Date) {
  //           $('td.rally-status', row).text("Active");
  //           $('td', row).css('background-color', '#efefef');
  //         }
  //       }
  //     }
  //   });

  //   $('.tooltipped').tooltip();
  //   $("#question-box").removeClass("hidden");
  // });

});
