#' Create a Frappe Chart
#'
#' Creates a Frappe Chart
#'
#' @import htmlwidgets
#'
#' @export
frappeChart <- function(
  data,
  type = c("line", "bar", "pie", "percentage", "heatmap"),
  title = "",
  ...,
  is_navigable = TRUE,
  width = NULL,
  height = 250,
  elementId = NULL
) {

  # forward options using x
  x = list(
    title = title,
    type = match.arg(type),
    height = height,
    data = data,
    isNavigable = is_navigable,
    ...
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'frappeChart',
    x,
    width = width,
    height = height,
    package = 'frappeCharts',
    elementId = elementId
  )
}

#' Shiny bindings for frappeChart
#'
#' Output and render functions for using frappeChart within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a frappeChart
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name frappeChart-shiny
#'
#' @export
frappeChartOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'frappeChart', width, height, package = 'frappeCharts')
}

#' @rdname frappeChart-shiny
#' @export
renderFrappeChart <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, frappeChartOutput, env, quoted = TRUE)
}

#' @rdname frappeChart-shiny
#' @export
updateFrappeChart <- function(inputId, data, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("frappeCharts:update", list(id = inputId, data = data))
}

.onLoad <- function(libname, pkgname) {
  shiny::registerInputHandler(
    type = "frappeCharts-selected",
    fun = function(value, session, inputName) {
      as.data.frame(value, stringsAsFactors = FALSE)
    }
  )
}
