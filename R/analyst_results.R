#' @title Results from ANALYST API
#'
#' @description Function to get results from your query ID.
#'
#' @returns Returns an object of class \code{list}.
#' @seealso , \code{\link{analyst_response}} \code{\link{analyst_id}}
#' @param id ID of the created query to be reused for querying results. 
#' @param subquery The subquery to be returned. 
#' @param variable A target variable for `aggregated`, `percentile` or `timeline` results. If `NULL` and `subquery == 'timeline'`, valid variables for query will be returned.
#' Ignored in all other subqueries. 
#' @param aggregation Aggregation mode for subquery `aggregated`, ignored in all other subqueries. 
#' @param percentile Percentile between 0 and 100 for subquery `percentile`, ignored in all other subqueries.
#' @param yearparts Partitioning of timeline with 1 for years, 2 for half-years, 4 for quarters and 12 for months. 
#' @export

analyst_results <- function(id = NULL,
														subquery = c('aggregated', 'count', 'offers', 'percentile', 'timeline'),
														variable = NULL,
														aggregation = c('AVG', 'MEDIAN', 'AVGFG', 'STDDEV', 'MIN', 'MAX', 'COUNT'),
														percentile = 50,
														yearparts = 1) {

	if (is.null(id)) stop("You must provide an ID to get subquery '", subquery,"'.")
	
	subquery <- rlang::arg_match(subquery)
	aggregation <- rlang::arg_match(aggregation)
	
	if (subquery == 'timeline' & !(yearparts %in% c(1,2,4,12))) {

		stop("You must provide integer 1, 2, 4 or 12 to yearparts for subquery 'timeline'")

	}
	

	if (subquery == 'aggregated' & is.null(variable)) {
		
		stop("You must provide a variable for subquery aggregation")
		
	}
		
	if (subquery == 'percentile') {
		
		if (is.null(percentile) || !dplyr::between(percentile, 0,100)) {
			
			stop('You must provide a percentile from 0 to 100.')
			
		}
		
		if ((is.null(variable) || variable == "")) {
			
			stop('You must provide a variable.')
			
		}
		
		
		}
			

		if (subquery %in% c('aggregated')) {
			
			path <- paste0("queryResults/",id,"/aggregated/",variable,"/",aggregation)
			
			} else if (subquery == 'count') {
				
				path <- paste0("queryResults/",id,"/count")
				
			} else if (subquery == 'offers') {
				
				path <- paste0("queryResults/",id,"/offers")
				
			} else if (subquery == 'percentile') {
				
				path <- paste0("queryResults/",id,"/percentile/",variable,"/",percentile)
				
			} else if (subquery == 'timeline') {
				
				queries <- analyst_response(path = paste0("queryResults/",id,"/timeline/variables"))
				
				if (is.null(variable)) {
					
					message("You will find available variables to get timeline results for your queryId ", id, " at values$keys.")

				} else if (!(variable %in% queries$values$key)) {
					
					stop(variable, " is not a valid variable for queryId ", id,". Use one of: ", paste0(queries$values$key, collapse = ", "),".")
					
				} else {
				
				path <- paste0("queryResults/",id,"/timeline?yearParts=",yearparts,"&aggregation=",aggregation,"&timelineVariable=", variable)
				
				}
				
			}
	
	if (subquery == 'timeline' && is.null(variable)) {
		
		
		queries$json <- jsonlite::toJSON(jsonlite::fromJSON(httr::content(queries$response, "text", encoding = 'UTF-8')))
		
		return(queries)
	
		} else {

  queries <- analyst_response(path = path)
  
  queries$json <- jsonlite::toJSON(jsonlite::fromJSON(httr::content(queries$response, "text", encoding = 'UTF-8')))
  
  return(queries)

		}

}

