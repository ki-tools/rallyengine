var q5 = {
  "A": "To what extent is growth faltering explained by prenatal vs postnatal insults?",
  "B": "What kind of recovery can we expect in infants born small for gestational age (SGA)?",
  "C": "Can we quantitatively characterize the relation and interaction between preterm birth, physical growth, and brain development?",
  "D": "Are there disproportionately large contributions to growth faltering from specific pathways, and can we rank-order risk factors?",
  "E": "Are there specific pathways directly impacting linear growth faltering that coincide with increased risk of noncommunicable diseases such as cardiovascular disease, obesity, and diabetes?"
}

$(document).ready(function(){
  $.getJSON('question_data.json', function(data) {

    var nq = 0;
    data.map(function(d) { if (d.rally_link !== undefined) { nq++;} })

    $('#title').html(data.length + ' Prioritized Questions with ' + nq + ' Addressed by Rallies To Date');

    var template = $('#template').html();
    Mustache.parse(template);   // optional, speeds up future uses
    var rendered = Mustache.render(template, data);
    $('#question-data').html(rendered);

    var table = $('#questions').DataTable({
      "fixedHeader": true,
      "paging": false,
      "order": [[ 2, "desc" ]],
      "language": {
        "info": "",
        "infoEmpty": "",
        "infoFiltered":   "Showing _TOTAL_ of _MAX_ questions"
      },
      "mark": true,
      "rowCallback": function(row, data, index) {
        // set the tooltip value
        var el = $('td.hbgd-cat > span', row);
        el.attr("data-tooltip", q5[el.text().trim()]);

        var nd = $('td.rally-status', row).attr("data-end");
        if (nd !== '') {
          var dt = new Date(nd);
          if (dt > new Date) {
            $('td.rally-status', row).text("Active");
            $('td', row).css('background-color', '#efefef');
          }
        }
      }
    });

    $('.tooltipped').tooltip();
    $("#question-box").removeClass("hidden");
  });

});
