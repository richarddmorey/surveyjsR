#' @importFrom htmltools htmlDependency
quilljs_dependency = htmltools::htmlDependency(
  name = "quilljs",
  version = "1.3.6",
  package = "surveyjsR",
  src = "htmlwidgets/lib/quilljs",
  script = c(
    "js/quill.js"
  ),
  stylesheet = c(
    "css/quill.snow.css"
  )
)

#' @importFrom htmltools htmlDependency
summernote_dependency = htmltools::htmlDependency(
  name = "summernote",
  version = "0.8.18",
  package = "surveyjsR",
  src = "htmlwidgets/lib/summernote",
  script = c(
    "js/summernote-lite.min.js"
  ),
  stylesheet = c(
    "css/summernote-lite.min.css"
  )
)
