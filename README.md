
# frappeCharts - An HTML Widgets Demo

<!-- badges: start -->
<!-- badges: end -->

[js4shiny]: https://js4shiny.com
[js4rsconf]: https://github.com/rstudio-conf-2020/js-for-shiny
[htmlwidget]: https://www.htmlwidgets.org/
[frappe-charts]: https://frappe.io/charts

This is a demo repository for the 
[JavaScript for Shiny Users workshop][js4shiny] at 
[rstudio::conf][js4rsconf].

The goal is to build an [htmlwidget]
around the [Frappe Charts][frappe-charts] JavaScript library.

The repository is itself a walk through of the project.
Walk through the 
[commit log](https://github.com/gadenbuie/js4shiny-frappeCharts/commits/master)
or read through the 
[dev journal](https://github.com/gadenbuie/js4shiny-frappeCharts/blob/master/dev/dev.md)
to explore the project and the changes made at each step of the process.

---

## Building Custom Shiny Inputs

&#x2728; Bonus! &#x2728;

This repo also contains a walkthough
building a custom Shiny input: 
a `<textarea>` input that measures typing speed.
At the end of the project,
we incorporate the `frappeCharts` widget
we built in the [main project](https://github.com/gadenbuie/js4shiny-frappeCharts/blob/master/dev/dev.md).

Walk through the 
[commit log of the shiny-input branch](https://github.com/gadenbuie/js4shiny-frappeCharts/commits/shiny-input)
or read through
[the shiny-input dev journal](https://github.com/gadenbuie/js4shiny-frappeCharts/tree/shiny-input/inst/shiny-input-app#readme)
to explore the project and the changes made at each step of the process.

The final app is available to demo at https://gadenbuie.shinyapps.io/type-racer/
