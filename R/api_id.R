#' @title Create query ID
#'
#' @description Create query ID on a given JSON, with the provided filter conditions. 
#'
#' @details The returned query ID can be used in subsequent API requests to access the data described by this query. 
#' The queryId is only valid for 6 hours, before it expires and has to be posted again.
#'
#' @returns If \code{query_id = TRUE}, \code{\link{api_id}} returns an integer, 
#' otherwise an object of class \code{api_class}, see \code{\link{api_class}}.
#' @seealso \code{\link{api_response}}
#' @param json Request body in JSON format.
#' @param query_id If TRUE, only the query ID is returned.
#' @param full_stats Usually only the most basic statistics for a query are pre-computed, 
#' but if this flag is true, a lot more statistics will be computed beforehand 
#' (with increased loading time for the query, but potentially decreased loading time for the statistics).
#' @examples \dontrun{
#' api_id(json = '{"segment": "WHG_K","administrativeSpatialFilter": {"postalCodes": [97070]}}')}
#' @export

api_id <- function(json = NULL,
									 query_id = FALSE,
									 full_stats = FALSE) {

	oo <- options("scipen")
	options(scipen = 999)
	on.exit(options(scipen = oo))
	
	if (is.null(json) || jsonlite::validate(json) == FALSE) stop("You must specify a valid json.", call. = FALSE)
	
  query <- api_response(path = paste0("queries?fullStats=",tolower(full_stats)), type = "POST", json = json)

  if (query_id) {
  	
  	return(query$values$queryId)
  	
  } else {
  		
  	return(query)
  	
  	}

}

# ?api_id(query_id = T, json = '{"segment": "WHG_M","administrativeSpatialFilter": {"postalCodes": [97070]}}')