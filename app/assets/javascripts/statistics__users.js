google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: "/statistics/users.json",
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      var users_chart = new google.visualization.LineChart(document.getElementById('users_chart'));
      var users_options = {
        focusTarget: 'category',
        title: 'Number of Registered Accounts',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'none'},
        width: 1000, height: 350
      };

      var weekly_signins_chart = new google.visualization.LineChart(document.getElementById('weekly_signins_chart'));
      var weekly_signins_options = {
        focusTarget: 'category',
        title: 'Weekly Signins',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'bottom'},
        width: 1000, height: 350
      };

      var signins_chart = new google.visualization.LineChart(document.getElementById('signins_chart'));
      var signins_options = {
        focusTarget: 'category',
        title: 'Signins (by Unique User)',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'none'},
        width: 1000, height: 350
      };

      drawUsersChart(data['users'], users_options, users_chart);
      drawWeeklySigninsChart(data['weekly_signins'], weekly_signins_options, weekly_signins_chart);
      drawSigninsChart(data['signins'], signins_options, signins_chart);
    }
  })
}

function drawChart(data_table, max_value, options, chart) {
  var desired_steps = 5;
  options.vAxis.gridlines = {count: graphGridLines(max_value, desired_steps)};
  options.vAxis.maxValue = graphStepSize(max_value, desired_steps) * (options.vAxis.gridlines.count - 1);
  chart.draw(data_table, options);
}

function drawUsersChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Date',
    pattern: 'DD MMM yyyy'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Users'
  });

  var users_data = data['data'];
  for(data_row in users_data) {
    row = new Array();
    row[0] = new Date(users_data[data_row]['date']);
    row[1] = users_data[data_row]['total'];
    data_table.addRow(row);
  }

  drawChart(data_table, data['max_value'], options, chart);
}

function drawWeeklySigninsChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'string',
    label: 'Day & Time'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Week ending yesterday'
  });
  data_table.addColumn({
    type: 'number',
    label: '4 weeks upto yesterday'
  });

  for(var x = 0; x < data['count']-1; x++) {
    row = new Array();
    row[0] = data['label'][x];
    row[1] = data['last_week'][x];
    row[2] = data['last_4_weeks'][x];
    data_table.addRow(row);
  }

  drawChart(data_table, data['max_value'], options, chart);
}

function drawSigninsChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Date',
    pattern: 'DD MMM yyyy'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Signins'
  });

  var signins_data = data['data'];
  for(data_row in signins_data) {
    row = new Array();
    row[0] = new Date(signins_data[data_row]['date']);
    row[1] = signins_data[data_row]['total'];
    data_table.addRow(row);
  }

  drawChart(data_table, data['max_value'], options, chart);
}
