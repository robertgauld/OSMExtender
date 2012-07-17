var colours = {
  'Red': 'FF0000',
  'Green': '00FF00',
  'Blue': '0000FF',
  'Yellow': 'FACF04',
  'Brown': '873E16',
  'Orange': 'DD520B',
  'Purple': '7B1974',
  'White': 'FFFFFF',
  'Grey': '808080',
  'Black': '222222'
}

var pins = {};
for (var colourName in colours) {
  pins[colourName] = new google.maps.MarkerImage(
    'http://chart.apis.google.com/chart?chst=d_map_pin_icon&chld=home|' + colours[colourName],
    new google.maps.Size(21, 34),
    new google.maps.Point(0,0),
    new google.maps.Point(10, 34)
  );
}

var pinBase = new google.maps.MarkerImage(
  'http://chart.apis.google.com/chart?chst=d_map_pin_icon&chld=star|AAFFAA',
  new google.maps.Size(21, 34),
  new google.maps.Point(0,0),
  new google.maps.Point(10, 34)
);

var pinShadow = new google.maps.MarkerImage(
  'http://chart.apis.google.com/chart?chst=d_map_pin_shadow',
  new google.maps.Size(40, 37),
  new google.maps.Point(0, 0),
  new google.maps.Point(12, 35)
);

var mapOptions = {
  zoom: 5,
  center: new google.maps.LatLng(55, -3),
  mapTypeControl: false,
  zoomControl: true,
  mapTypeId: google.maps.MapTypeId.ROADMAP
}

var map = null;
var bounds = null;
var geocoder = new google.maps.Geocoder();
var groupings = null;
var markers = null;
var membersAll = 0;
var membersDone = 0;

// Allow member to be inscope in callback function
var plotMember = function(member) {
  return function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var location = results[0].geometry.location;
      if (markers[location] == null) { // We've not yet seen this location
        members[location] = [member];
        var marker = new google.maps.Marker({
          position: location,
          map: map,
          icon: pins[document.getElementById('pin-' + member.grouping_id).value],
          shadow: pinShadow,
          clickable: true,
          title: member.name
        });
        marker.info = new google.maps.InfoWindow({
          content: member.name
        });
        google.maps.event.addListener(marker, 'click', function() {
          marker.info.open(map, marker);
        });
        markers[location] = marker;
        map.fitBounds(bounds.extend(location));
      } else { // We've already seen this location;
        members[location].push(member);
        var listOfMembers = '';
        var membersInSameGrouping = members[location][0].grouping_id;
        for(var index in members[location]) {
          var this_member = members[location][index];
          listOfMembers += '<li>' + this_member.name + '</li>';
          if (this_member.grouping_id != membersInSameGrouping) {membersInSameGrouping = null;}
        }
        if (membersInSameGrouping == null) {  // members are not in the same grouping
          markers[location].setIcon(new google.maps.MarkerImage(
            'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + members[location].length + '|AAAAFF',
            new google.maps.Size(21, 34),
            new google.maps.Point(0,0),
            new google.maps.Point(10, 34)
          ));
        } else {
          markers[location].setIcon(new google.maps.MarkerImage(
            'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + members[location].length + '|' + colours[document.getElementById('pin-' + member.grouping_id).value],
            new google.maps.Size(21, 34),
            new google.maps.Point(0,0),
            new google.maps.Point(10, 34)
          ));
        }
        markers[location].setTitle('Multiple members.');
        markers[location].info = new google.maps.InfoWindow({
          content: '<ul>' + listOfMembers + '</ul>'
        });
      }
      incrementProgress();
    } else {
      appendStatus(member.name + ' not included (' + status + ')');
    }
  }
}

// Allow member to be inscope in callback function
var geocodeMember = function(member) {
  return function() {
    geocoder.geocode( { 'address': member.address}, plotMember(member));
  }
}

function plot() {
  bounds = new google.maps.LatLngBounds();
  map = new google.maps.Map(document.getElementById("map"), mapOptions);
  markers = {};
  members = {};
  membersDone = 0;
  $("#errors").html('');
  $("#progress").html('Fetching map.');
  var base = document.getElementById('base').value;
  if (base.length > 0) {
    geocoder.geocode( { 'address': base}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        var location = results[0].geometry.location;
        var marker = new google.maps.Marker({
          position: location,
          map: map,
          icon: pinBase,
          shadow: pinShadow,
          clickable: true,
          title: 'Meeting place'
        });
        map.fitBounds(bounds.extend(location));
      } else {
        appendStatus('Meeting place not included (' + status + ')');
      }
    });
  }
  $.ajax({
    url: '/map_members/data?address=' + document.getElementById('address').value,
    dataType:'json',
    async: false,
    success: function(data, status, jqXHR) {
      groupings = data['groupings'];
      membersAll = data['members'].length;
      for (var index in data['members']) {
        var member = data['members'][index];
        if (member.address.length > 0) {
          setTimeout(geocodeMember(member), (index * 1000));   // Don't hammer the API too fast
        } else {
          appendStatus(member.name + ' not included (does not have selected address)');
        }
      }
    }
  });
}


function appendError(message) {
  $("#errors").html($("#errors").html() + ($("#errors").html().length > 0 ? '<br/>' : '') + message);
}

function incrementProgress() {
  ++membersDone;
  progress = (membersDone < membersAll) ? 'Completed ' + membersDone + ' of ' + membersAll + '.' : 'Finished.';
  $("#progress").html(progress);
}