HTMLWidgets.widget({

  name: 'frappeChart',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        const chartData = {labels: [], datasets: []}

        // Get keys of data, assume that first entry is for labels, the rest are data
        let labelColumn = Object.keys(x.data)[0]
        let columns = Object.keys(x.data).slice(1)

        // First column in x.data is the labels
        chartData.labels = x.data[labelColumn]

        // Create an appropriate object for each column, reformat data and add to chartData
        columns.forEach(function(col) {
          chartData.datasets.push({name: col, values: x.data[col]})
        })

        x.data = chartData

        const chart = new frappe.Chart(el, x)

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
