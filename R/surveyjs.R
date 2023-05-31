#' surveyjs widget
#'
#' surveyjs widget
#'
#' @import htmlwidgets
#' @importFrom jquerylib jquery_core
#'
#' @export
surveyjs <- function(survey, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    model = survey$model(json=FALSE),
    data = list()
  )

  dependencies = list(
    jquerylib::jquery_core(3),
    htmltools::htmlDependency(
      name = "surveyjs",
      version = "1.9.90",
      package = "surveyjsR",
      src = "htmlwidgets/lib/surveyjs",
      script = c(
        "js/survey-jquery-1.9.90.min.js",
        "js/widgets/quill_widget.js",
        "js/widgets/summer_widget.js"
      ),
      stylesheet = c(
        "css/defaultV2.min.css"
      )
    )
  )

  if(any(survey$survey()$type == 'quilledit'))
    dependencies[[length(dependencies)+1]] = quilljs_dependency

  if(any(survey$survey()$type == 'summeredit'))
    dependencies[[length(dependencies)+1]] = summernote_dependency

  # create widget
  htmlwidgets::createWidget(
    name = 'surveyjs',
    x,
    width = width,
    height = height,
    package = 'surveyjsR',
    elementId = elementId,
    dependencies = dependencies
  )
}

#' Shiny bindings for surveyjs
#'
#' Output and render functions for using surveyjs within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a surveyjs
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name surveyjs-shiny
#'
#' @export
surveyjsOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'surveyjs', width, height, package = 'surveyjsR')
}

#' @rdname surveyjs-shiny
#' @export
renderSurveyjs <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, surveyjsOutput, env, quoted = TRUE)
}
