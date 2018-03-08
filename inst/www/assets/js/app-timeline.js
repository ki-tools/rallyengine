$( function() {
  var SERVER = 'rally_data.json';
  if (window.RALLY_API_SERVER !== undefined) {
    SERVER = window.RALLY_API_SERVER + '/dashboard';
  }
  $.getJSON(SERVER, function(data) {

    // var groups = {};
    // for (var i = 0; i < data.length; i++) {
    //   var id = parseInt(data[i].group.num);
    //   groups[id] = {
    //     id: id,
    //     content: 'Rally ' + id + ': ' + data[i].group.name,
    //     value: id
    //   };
    // }

    var groups = new vis.DataSet([
      {id: 1, content: 'Rally 1: Gestational Age Estimation', value: 1},
      {id: 2, content: 'Rally 2: Fetal Growth Patterns', value: 2},
      {id: 3, content: 'Rally 3: GA Estimation Ultrasound', value: 3},
      {id: 4, content: 'Rally 4: Wasting', value: 4},
      {id: 5, content: 'Rally 5: GA Shift Analysis', value: 5},
      {id: 6, content: 'Rally 6: India Data', value: 6},
      {id: 7, content: 'Rally 7: Stunting', value: 7}
    ]);

    var items2 = data.map(function(d, i) {
      return ({
        id: i,
        group: d.rally,
        content: d.rally + d.sprint,
        start: new Date(d.timeline.start),
        end: new Date(d.timeline.end),
        className: 'gp' + (d.rally - 1),
        title: d.title + '<br />' + d.timeline.start + ' &#8211; ' + d.timeline.end,
        overview_link: d.overview_link
      })
    });

    var items = new vis.DataSet(items2);

    // create a dataset with items
    // note that months are zero-based in the JavaScript Date object, so month 3 is April
    // var items_old = new vis.DataSet([
    //   {id: 0, group: 1, content: '1A', start: new Date(2017, 5, 7), end: new Date(2017, 5, 21),
    //     className: 'gp0', title: 'Accuracy and Precision in Gestational Age Measurement: Physical Assessment Tools<br />2017-06-7 &#8211; 2017-06-21'},
    //   {id: 1, group: 1, content: '1B', start: new Date(2017, 6, 13), end: new Date(2017, 6, 31),
    //     className: 'gp0', title: 'Accuracy and Precision in Gestational Age Measurement: Physical Assessment Tools<br />2017-07-13 &#8211; 2017-07-31'},
    //   {id: 2, group: 2, content: '2A', start: new Date(2017, 6, 16), end: new Date(2017, 6, 30),
    //     className: 'gp1', title: 'Characterizing Fetal Growth and Relations Between Maternal Covariates, Fetal Growth, and Birth Outcomes<br />2017-07-06 &#8211; 2017-07-13'},
    //   {id: 3, group: 2, content: '2B', start: new Date(2017, 7, 3), end: new Date(2017, 7, 17),
    //     className: 'gp1', title: 'Fetal Growth: One Standard Fits all?<br />2017-08-03 &#8211; 2017-08-17'},
    //   {id: 4, group: 4, content: '4A', start: new Date(2017, 6, 21), end: new Date(2017, 7, 7),
    //     className: 'gp3', title: 'Descriptive Epidemiology of Wasting<br />2017-07-21 &#8211; 2017-08-07'},
    //   {id: 5, group: 4, content: '4B', start: new Date(2017, 6, 21), end: new Date(2017, 7, 7),
    //     className: 'gp3', title: 'Pilot of the Analysis of Risk Factors for Wasting Incidence and Recovery<br />2017-07-21 &#8211; 2017-08-07'},
    //   {id: 6, group: 4, content: '4C', start: new Date(2017, 7, 8), end: new Date(2017, 8, 14),
    //     className: 'gp3', title: 'Dose-Response Relationship of Breastfeeding on Wasting<br />2017-07-21 &#8211; 2017-08-07'},
    //   {id: 7, group: 4, content: '4D', start: new Date(2017, 8, 25), end: new Date(2017, 9, 10),
    //     className: 'gp3', title: 'Wasting Analysis Clean-Up and Documentation<br />2017-07-21 &#8211; 2017-08-07'},
    //   {id: 8, group: 5, content: '5A', start: new Date(2017, 8, 25), end: new Date(2017, 9, 10),
    //     className: 'gp4', title: 'Gestational Age Shift Analysis<br />2017-07-21 &#8211; 2017-08-07'}
    // ]);

    var today = new Date();

    // create rallytimeline
    var container = document.getElementById('rallytimeline');
    var options = {
      // option groupOrder can be a property name or a sort function
      // the sort function must compare two groups and return a value
      //     > 0 when a > b
      //     < 0 when a < b
      //       0 when a == b
      groupOrder: function (a, b) {
        return a.value - b.value;
      },
      editable: false,
      showTooltips: true,
      tooltip: { followMouse: true },
      selectable: false,
      end: new Date(today.getTime() + 2 * 24 * 60 * 60 * 1000)
    };

    var timeline = new vis.Timeline(container);
    timeline.setOptions(options);
    timeline.setGroups(groups);
    timeline.setItems(items);

    document.getElementById('rallytimeline').onclick = function (event) {
      var props = timeline.getEventProperties(event)
      if (props.what === 'item') {
        window.open(items2[props.item].overview_link, '_blank');
      }
    }
  });
});
