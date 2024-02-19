#' @title Queries from ANALYST API
#'
#' @description Function to get additional infornation on query.
#'
#' @returns Returns an object of class \code{list}.
#' @seealso \code{\link{analyst_response}}
#' @param id ID of the created query to be reused for querying results. 
#' @param subquery The subquery to be returned. 
#' @param limit Limit of returned benchmark queries (default: 10), ignored if subquery is not `benchmarks`. 
#' @export

analyst_queries <- function(id = NULL,
														subquery = c('counterpart', 'limit', 'benchmarks', 'queryId'),
														limit = 10) {
	
	subquery <- rlang::arg_match(subquery)

	if (is.null(id) & subquery != 'limit') stop("You must provide an ID to get subquery '", subquery,"'.")
	
	if (is.null(id) | subquery == 'limit') {	
		
		path <- paste0("queries/limit")
		
	} else {
	
		if (subquery %in% c('counterpart')) {
			
			path <- paste0("queries/",id,"/",subquery)
			
			} else if (subquery == 'benchmarks') {
				
				path <- paste0("queries/",id,"/",subquery,"?limit=",limit)
				
			} else if (subquery == 'queryId') {
				
				path <- paste0("queries/",id)
				
			}
		
		
	}
	


  queries <- analyst_response(path = path)
  
  queries$json <- jsonlite::toJSON(jsonlite::fromJSON(httr::content(queries$response, "text", encoding = 'UTF-8')))
  
  return(queries)


}
