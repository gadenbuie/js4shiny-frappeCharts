HTMLWidgets.widget({

  name: 'frappeChart',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    // we'll create chart in renderValue but want to access it elsewhere
    let chart = null

    // helper function to prep the data
    const prepareChartData = function(data) {
      const chartData = {labels: [], datasets: []}

      // Get keys of data, assume that first entry is for labels, the rest are data
      let labelColumn = Object.keys(data)[0]
      let columns = Object.keys(data).slice(1)

      // First column in x.data is the labels
      chartData.labels = data[labelColumn]

      // Create an appropriate object for each column, reformat data and add to chartData
      columns.forEach(function(col) {
        chartData.datasets.push({name: col, values: data[col]})
      })
      return chartData
    }

    return {

      renderValue: function(x) {
        el.widget = this
        let labelsName = Object.keys(x.data)[0]
        x.data = prepareChartData(x.data)

        chart = new frappe.Chart(el, x)

        if (HTMLWidgets.shinyMode && x.isNavigable) {
          el.addEventListener('data-select', function(ev) {
            let {index, values} = ev
            let chart = el.widget.chart()
            let label = chart.data.labels[index]
            let names = chart.data.datasets.map(d => d.name)
            let data = values.reduce(function(acc, v, idx) {
              acc[names[idx]] = v
              return acc
            }, {})
            data[labelsName] = label
            Shiny.setInputValue(el.id + '_selected', data)
          })
        }
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      },

      update: function(data) {
        if (!chart) {
          console.error("The chart has not yet been initialized.")
        }
        let chartData = prepareChartData(data)
        chart.update(chartData)
      },

      chart: () => chart

    };
  }
});

if (HTMLWidgets.shinyMode) {
  Shiny.addCustomMessageHandler('frappeCharts:update', function({id, data}) {
    let el = document.getElementById(id)
    if (el.widget) {
      el.widget.update(data)
    }
  })
}
