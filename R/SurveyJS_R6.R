
#' @importFrom dplyr filter arrange first last pull group_by mutate
#' @importFrom dplyr row_number case_when ungroup select
#' @importFrom R6 R6Class
#' @importFrom jsonlite toJSON
#'
#' @export
survey <- R6::R6Class(
  "survey",
  private = list(
    survey_df = NULL,
    questions_lst = NULL,
    empty_df = data.frame(
      name = character(0),
      sort = integer(0),
      page = integer(0),
      panel = character(0),
      type = character(0)
    )
  ),
  public = list(
    settings = NULL,
    initialize = function(survey = NULL, questions = list(), settings = list()) {

      if(is.null(survey))
        survey = private$empty_df

      # Create page column if it doesn't exist
      # (with everything on same page)
      if(is.null(survey$page))
        survey$page = rep(1L, nrow(survey))

      # Create panel column if it doesn't exist
      # (with everything on panel)
      if(is.null(survey$panel))
        survey$panel = rep(NA_character_, nrow(survey))

      # Convert pages to sequential integers
      survey$page = rank(survey$page, ties.method = 'min') |> factor() |> as.integer()

      # Create sort column if it doesn't exist
      if(is.null(survey$sort))
        survey$sort = seq(length.out = nrow(survey))

      private$survey_df <- survey
      private$questions_lst <- questions
      self$settings <- settings

      self$validate()

    },
    validate = function(){

      settings = self$settings
      questions = private$questions_lst
      survey = private$survey_df

      # Check data frame
      stopifnot(is.data.frame(survey))
      stopifnot(all(colnames(private$empty_df) %in% colnames(survey)))
      stopifnot(length(unique(survey$name))==nrow(survey))

      stopifnot(is.character(survey$type))
      stopifnot(is.character(survey$name))

      cn = colnames(private$empty_df)
      cn = cn[cn != "panel"]
      NAs_in = sapply(cn, \(el){
        any(is.na(survey[[el]]))
      })
      if(any(NAs_in))
        stop('Missing in survey values not allowed. See survey column(s): ', colnames(private$empty_df)[NAs_in])

      # Check questions list
      stopifnot(length(questions) == nrow(survey))
      stopifnot(length(names(questions)) == nrow(survey))
      stopifnot(all(names(questions) %in% survey$name))
      stopifnot(all(survey$name %in% names(questions)))

      Q_empty = sapply(questions, \(el){
        length(el)==0
      })
      if(any(Q_empty))
        stop('Empty questions not allowed. See question(s) in list: ', names(questions)[Q_empty])

      # Check settings
      stopifnot(is.list(settings))
      stopifnot(!length(settings) || !is.null(names(settings)))
      unique_settings_names = unique(names(settings))
      if(length(unique_settings_names) != length(settings))
        stop("All settings names must be unique.")

      invisible(self)
    },
    print = function(...) {
      nq = length(private$questions_lst)
      cat('There', ifelse(nq==1,'is','are'), nq, 'question(s) in the survey.\n\n')
      if(nq==0) return(invisible(self))

      s = self$survey()
      lapply(seq(length.out = nrow(s)), \(i){
        v = s[i,]
        cat('Question ', v$q,
            ' is "', v$name,
            '" and is of type "', v$type,
            '" on page ', v$page,
            '. It has settings: ', private$questions_lst[[v$name]] |> names() |> paste(collapse=','),
            '.\n',
            sep='')
      })
      invisible(self)
    },
    add = function(name, type, page = NULL, panel = NA, sort = NULL, ...){
      args = list(...)
      if(length(args)==0)
        stop('No question content was specified.')

      if(name %in% names(private$questions_lst) || name %in% private$survey_df$name)
        stop('Question name must not be the same as an existing question name.')

      if(length(page)>1 || length(sort)>1)
        stop('Arguments page and sort must be at most of length 1.')

      if(length(name)!=1 || length(type)!=1 || length(panel)!=1)
        stop('Arguments name, type, and panel must be of length 1.')

      s = private$survey_df

      if(nrow(s)==0 && (is.null(page) || page == Inf)){
        page = 1
        if(is.null(sort))
          sort = 'a'
      }else if(is.null(page)){
        page = max(s$page)
      }else if(page == Inf){
        page = max(s$page) + 1L
        if(is.null(sort))
          sort = 'a'
      }else{
        stopifnot(page %in% s$page)
      }

      if(is.null(sort)){
        s |>
          dplyr::filter(page == page) |>
          dplyr::arrange(sort) |>
          dplyr::last() |>
          dplyr::pull(sort) -> last_sort
        sort = paste0(last_sort,'_')
      }

      new_line = data.frame(
        name = name,
        type = type,
        sort = sort,
        page = page,
        panel = panel
      ) |>
        rbind(s) -> s

      private$survey_df = s
      private$questions_lst[[name]] = args
      self$validate()
    },
    remove = function(names){
      idx = match(names, private$survey_df$name)
      if(any(is.na(idx))){
        stop('Could not find question(s): ', names[is.na(idx)])
      }
      if(length(names)==0) return(invisible(self))

      # Remove from survey_df
      private$survey_df |>
        dplyr::filter(
          !(name %in% names)
        ) -> private$survey_df

      # Remove from questions_lst
      keep = which(!(names(private$questions_lst) %in% names))
      private$questions_lst = private$questions_lst[keep]

      self$validate()
    },
    sortkeys = function(names, sortkeys){

      idx = match(names, private$survey_df$name)
      if(any(is.na(idx))){
        stop('Could not find question(s): ', names[is.na(idx)])
      }

      stopifnot(length(names)==length(sortkeys))
      if(length(names)==0) return(invisible(self))

      private$survey_df$sort[idx] = sortkeys

      invisible(self)
    },
    gather_to_panel = function(names, panel){

      idx = match(names, private$survey_df$name)
      if(any(is.na(idx))){
        stop('Could not find question(s): ', names[is.na(idx)])
      }

      if(length(names)==0) return(invisible(self))
      stopifnot(length(panel)==1)

      pages = private$survey_df$page[idx]
      if(length(unique(pages))>1)
        stop('Elements to gather into panel must be on the same page.')

      private$survey_df$panel[idx] = panel

      invisible(self)
    },
    gather_to_page = function(names, page = Inf){

      idx = match(names, private$survey_df$name)
      if(any(is.na(idx))){
        stop('Could not find question(s): ', names[is.na(idx)])
      }

      if(length(names)==0) return(invisible(self))
      stopifnot(length(page)==1)
      stopifnot(is.numeric(page))
      stopifnot(page>0)

      s = private$survey_df

      if(page == Inf || page > max(s$page)){
        page = max(s$page) + 1L
      }else{
        page = as.integer(ceiling(page))
        if(is.na(page))
          stop("Argument 'page' could not be coerced to an integer.")
      }
      private$survey_df$page[idx] = page

      invisible(self)
    },
    model = function(page_names = NULL, json = TRUE){
      self$validate()
      s = self$survey()
      pages = split(s, s$page)
      if(is.null(page_names))
        page_names = names(pages)
      names(pages) = NULL
      stopifnot(length(page_names)==length(pages))
      seq(length.out = length(pages)) |>
        lapply(\(i){
          info = rle(pages[[i]]$panel)
          info$starts = cumsum(info$lengths) - info$lengths + 1
          f0 = function(j){
            r = pages[[i]][j,]
            list(name = r$name, type = r$type) |>
              c(private$questions_lst[[r$name]])
          }
          content = mapply(\(l,v,s){
            if(is.na(v)){
              return(f0(s))
            }else{
              return(
                list(
                  type = 'panel',
                  name = v,
                  elements=lapply(s:(s+l-1), FUN=f0)
                )
              )
            }
          }, l = info$lengths, v=info$values, s=info$starts, SIMPLIFY = FALSE)
          list(
            name = page_names[i],
            elements = content
          )
        }) |>
        list(pages = _) -> ps

      lst = c(self$settings, ps)

      if(json){
        return(jsonlite::toJSON(lst, auto_unbox = TRUE))
      }else{
        return(lst)
      }
    },
    survey = function(){
      private$survey_df |>
        dplyr::mutate(
          page = rank(page, ties.method = 'min') |> factor() |> as.integer()
        ) |>
        dplyr::arrange(page, sort) |>
        dplyr::group_by(page) |>
        dplyr::mutate(
          rn = dplyr::row_number()
        ) |>
        dplyr::group_by(page,panel) |>
        dplyr::mutate(
          rn = dplyr::case_when(
            is.na(panel) ~ rn,
            TRUE ~ dplyr::first(rn)
          )
        ) |>
        dplyr::ungroup() |>
        dplyr::arrange(page,rn,sort) |>
        dplyr::mutate(
          q = dplyr::row_number()
        ) |>
        dplyr::select(q, name, page, panel, type, sort)
    }
  )
)
