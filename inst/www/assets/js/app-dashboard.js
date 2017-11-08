function unique(list) {
  var result = [];
  $.each(list, function(i, e) {
    if ($.inArray(e, result) == -1) result.push(e);
  });
  return result;
}

$( function() {
  var SERVER = 'rally_data.json';
  if (window.RALLY_API_SERVER !== undefined) {
    SERVER = window.RALLY_API_SERVER + '/dashboard';
  }
  $.getJSON(SERVER, function(data) {

    var ncomplete = 0;
    for (var i = 0; i < data.length; i++) {
      var complete = new Date(data[i].timeline.end) < new Date;
      data[i].complete = complete ? "Complete" : "Active";
      ncomplete += complete;
    }

    // pre-sort the data so there's not animation on load
    data.sort(function compare(a, b) {
      var aval = a.timeline.start;
      var bval = b.timeline.start;
      if (aval === null) {
        aval = '';
      }
      if (bval === null) {
        bval = '';
      }
      if (aval > bval)
        return -1;
      if (aval < bval)
        return 1;
      return 0;
    });

    var nrallies = unique(data.map(function(d) { return d.group.num; })).length;

    $('#title').html((data.length - ncomplete) + ' Active Sprints and ' + ncomplete +
      ' Completed Sprints from ' + nrallies + ' Rallies');

    var template = $('#template').html();
    Mustache.parse(template);   // optional, speeds up future uses
    var rendered = Mustache.render(template, data);
    $('#grid').html(rendered);

    // go through and fix the height of the "Focus" section
    $('.rally-content').each(function() {
      var pp = $(this).find('p');
      var hh = 0;
      pp.each(function() {
        if (! $(this).hasClass('rally-focus')) {
          hh += $(this).height();
        }
      });
      $(this).find('.rally-focus').css('height', (270 - hh) + 'px');
    });

    // count number of participants to populate dropdown
    // and key it so it can be alphabetized by participant
    var rally_participants = {};
    $('.rally-participant-name').each(function() {
      var cur_participant = $(this).html();
      if (cur_participant !== "") {
        var lcur_participant = cur_participant.toLowerCase();
        if(rally_participants[lcur_participant] === undefined)
          rally_participants[lcur_participant] = {participant: cur_participant, count: 0};
        rally_participants[lcur_participant].count = rally_participants[lcur_participant].count + 1;
      }
    });

    // populate the participant filter dropdown
    $.each(Object.keys(rally_participants).sort(), function (i, val) {
      $('#participantfilter').append($('<option/>', {
        value: rally_participants[val].participant,
        text : rally_participants[val].participant + ' (' + rally_participants[val].count + ')'
      }));
    });

    // count tags to populate dropdown
    // and key it so it can be alphabetized by participant
    var rally_tags = {};
    $('.rally-tags').each(function() {
      var cur_tags = $(this).html();
      cur_tags = cur_tags.split(',');
      for (var i = 0; i < cur_tags.length; i++) {
        var cur_tag = cur_tags[i].trim();
        var lcur_tag = cur_tag.toLowerCase();
        if(cur_tag !== '') {
          if(rally_tags[lcur_tag] === undefined)
            rally_tags[lcur_tag] = {tag: cur_tag, count: 0};
          rally_tags[lcur_tag].count = rally_tags[lcur_tag].count + 1;
        }
      }
    });

    // populate the tag filter dropdown
    $.each(Object.keys(rally_tags).sort(), function (i, val) {
      $('#tagfilter').append($('<option/>', {
        value: rally_tags[val].tag,
        text : rally_tags[val].tag + ' (' + rally_tags[val].count + ')'
      }));
    });

    // initialize participant and tag select dropdowns
    $('select').material_select();

    var $grid = $('#grid');

    $grid.isotope({
      itemSelector : '.grid-item',
      layoutMode: 'masonry',
      getSortData: {
        startdate: function(itemElem) {
          var dt = $(itemElem).find('.start-date').text();
          return dt;
          // var ddt = new Date(dt)
          // return ddt;
        },
        name: function(itemElem) {
          var num = $(itemElem).find('.rally-num').text().toLowerCase();
          var chr = $(itemElem).find('.sprint-num').text().toLowerCase();
          var pad = "0000"
          var res = pad.substring(0, pad.length - num.length) + num + chr;
          return res;
        }
      },
      masonry: {
        isFitWidth: true,
        gutter: 20
      }
    });

    // use value of search field to filter
    var $textfilter = $('#textfilter').keyup( debounce( function() {
      $('#currentcheckbox').prop('checked', false);
      if(! $('#tagfilter').val() === '') {
        $('#tagfilter').val(0);
        $('#tagfilter').material_select();
      }
      if(! $('#participantfilter').val() === '') {
        $('#participantfilter').val(0);
        $('#participantfilter').material_select();
      }
      handleFilter();
    }, 100 ) );

    // trigger isotope sort on #gridsort change
    $('#gridsort').change(function() {
      var sortVal = $(this).val();
      // if(sortVal === 'stars')
      // $grid.isotope('updateSortData');
      $grid.isotope({ sortBy : sortVal, sortAscending: sortVal === 'startdate' ? false : true });
    });

    // trigger isotope filter on #participantfilter change
    // this resets tag and text filters and unchecks "current" checkbox, as the
    // number in the dropdown is for all rallies by this participant
    $('#participantfilter').change(function() {
      $('#tagfilter').val(0);
      $('#tagfilter').material_select();
      $('#textfilter').val('');
      $('#currentcheckbox').prop('checked', false);
      handleFilter();
    });

    // trigger isotope filter on #tagfilter change
    // this resets participant and text filters and unchecks the current, as the
    // number in the dropdown is for all rallies by this participant
    $('#tagfilter').change(function() {
      $('#participantfilter').val(0);
      $('#participantfilter').material_select();
      $('#textfilter').val('');
      $('#currentcheckbox').prop('checked', false);
      handleFilter();
    });

    // trigger isotope filter on #currentcheckbox change
    $('#currentcheckbox').click(function() {
      handleFilter();
    });

    // look at all filter inputs and determine which ones to show
    function handleFilter() {
      var tagVal = $('#tagfilter').val();
      var participantVal = $('#participantfilter').val();
      var textVal = $('#textfilter').val();
      var qsRegex;

      console.log('tagVal: ' + tagVal);
      console.log('participantVal: ' + participantVal);
      console.log('textVal: ' + textVal);
      console.log('qsRegex: ' + qsRegex);

      $grid.isotope({ filter : function() {
        var textBool = true;
        if(textVal !== '') {
          qsRegex = new RegExp( textVal, 'gi' );
          curText = $(this).find('.rally-title').html() + ' ' + $(this).find('.rally-focus').html() + ' ' + $(this).find('.rally-participant').html() + ' ' + $(this).find('.rally-tags').html();
          textBool = qsRegex.test(curText);
        }

        var tagBool = true;
        if(! (tagVal === '' || tagVal === null)) {
          tagBool = false;
          var tags = $(this).find('.rally-tags').html();
          tags = tags.split(',');
          for (var i = 0; i < tags.length; i++) {
            tagBool = tagBool || (tags[i].trim() === tagVal);
          }
        }

        var participantBool = true;
        if(! (participantVal === '' || participantVal === null)) {
          participantBool = false;
          $(this).find('.rally-participant-name').map(function(i, d) {
            participantBool = participantBool || $(d).text() === participantVal;
          })
        }

        var currentBool = $(this).find('.rally-current').html() === 'Active';
        if($('#currentcheckbox:checked').length === 0) {
          currentBool = true;
        }

        var res = textBool && tagBool && participantBool && currentBool;
        if(res) {
          $(this).addClass('is-showing');
        } else {
          $(this).removeClass('is-showing');
        }
        return res;
      }});
      $('#shown-rallies').html($('.is-showing').length + ' of ' + data.length);
    }

    // wrap hrefs around the tag listings for each rally
    // so when clicked they can fire off a filter on that tag
    $('.rally-tags').each(function(i) {
      var tagVals = $(this).html().split(',');
      $(this).addClass('hidden');
      for (var j = 0; j < tagVals.length; j++) {
        var el = document.createElement('a');
        el.className = 'taghref';
        el.textContent = tagVals[j];
        el.href = 'javascript:;';
        $(this).before(el);
        if (j < tagVals.length - 1) {
          $(this).before(', ');
        }
      }
    });

    // handle click on tag hrefs
    $('.taghref').click(function() {
      $('#tagfilter > option').removeAttr('selected');
      $('#tagfilter > option[value="' + $(this).html() + '"]').attr('selected', 'selected');
      $('select').material_select();
      $('#tagfilter').trigger('change');
    });

    // handle click on participants
    $('.rally-participant-name').click(function() {
      $('#participantfilter > option').removeAttr('selected');
      $('#participantfilter > option[value="' + $(this).html() + '"]').attr('selected', 'selected');
      $('select').material_select();
      $('#participantfilter').trigger('change');
    });

    // enforce initial filter (none)
    handleFilter();

    // enforce initial sort
    // $grid.isotope({ sortBy : 'startdate', sortAscending: false })

    // make sure 'Showing x of n' is correct
    var curlen = $('.rally-current').filter(function() {return $(this).html() === 'true'}).length;
    $('#shown-rallys').html(curlen);
  });
});

function debounce( fn, threshold ) {
  var timeout;
  return function debounced() {
    if ( timeout ) {
      clearTimeout( timeout );
    }
    function delayed() {
      fn();
      timeout = null;
    }
    timeout = setTimeout( delayed, threshold || 100 );
  };
}



// var $grid = $('.grid').isotope({
//   itemSelector: '.grid-item',
//   isFitWidth: true
//   // percentPosition: true,
//   // masonry: {
//   //   // use element for option
//   //   columnWidth: '.grid-item',
//   //   rowHeight: '.grid-item'
//   // }
// });


