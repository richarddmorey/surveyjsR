
#' Compile child Rmd document into html character vector
#'
#' @param child_rmd path of child Rmd to compile
#' @param td temporary directory to use for compilation
#' @param ... arguments to pass to rmarkdown::render
#'
#' @return A character vector of length 1 containing the compiled html
#' @export
#'
#' @importFrom rmarkdown render
#'
#' @examples
sjsR_renderChild = function(child_rmd, td = tempdir(), ...){
  tf = tempfile(tmpdir = td, fileext = '.html')
  rmarkdown::render(
    child_rmd,
    output_format =
      rmarkdown::html_fragment(
        pandoc_args = rmarkdown::pandoc_metadata_arg('title','.')
        ),
    output_file = tf, quiet=TRUE,
    ...
  ) |>
    readLines() |>
    paste(collapse='\n') -> res

  unlink(tf)
  return(res)
}
