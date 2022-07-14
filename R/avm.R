#' @title Request values from AVM indications
#'
#' @description Function to receive values from AVM API. 
#'
#' @details 
#' It returns a list of data frames with all input parameters including input categories 
#' and all output paramaters including information on JSON output.
#' Columns with example, minimal or maximal values might also contain dates, that's why they return characters. 
#' 
#' @returns An object of class \code{\link{avm_class}}.
#' 
#' @seealso \code{\link{avm_response}}, \code{\link{avm_indications}}, \code{\link{avm_segments}}
#' @importFrom foreach %do%
#' @param indication The indication you want to send your request to, e.g. `MARKET_VALUE`. See also \code{\link{avm_indications}} to get all licensed indications. 
#' @param json Request body in JSON format.
#' @param metrics If TRUE, model metrics will be included if available and licensed for chosen indication. 
#' @param details If TRUE, details will be included if available and licensed for chosen indication.
#' @param ignore_error If TRUE, \code{\link{avm_response}} will not stop on error. 
#' This is usefull for parallel requests to avoid that function stops on single errors.
#' Defaults to \code{FALSE}.
#' @examples \dontrun{
#' 	
#' json <- '{
#' "address": "Heidestraße 8, 10557 Berlin",
#' "segment": "WHG_K",
#' "space_living": 100,
#' "year_of_construction": 1990,
#' "quality_furnishings": 1
#' }'
#' 	
#' avm(indication = 'COMPARATIVE_VALUE', json = json, ignore_error = T)
#' 
#' }
#' @export

avm <- function(indication = NULL,
								json = NULL, 
								metrics = FALSE, 
								details = FALSE,
								market_stats = FALSE,
								comparables = NULL) {

	
	oo <- options("scipen")
	options(scipen = 999)
	on.exit(options(scipen = oo))
	
  if (!(indication %in% valuer$avm_indications$indication)) stop("You asked for an unknown indication", call. = FALSE)

  if (is.null(json) || jsonlite::validate(json) == FALSE) stop("You must specify a valid json.", call. = FALSE)
  
  # get values
	
	indication_in <- indication
	
  relative_url <- valuer$avm_indications %>% dplyr::filter(indication == indication_in) 
  
  path <- relative_url$relativeUrl

  # set flags
  
  if (details) {
  	
  	if (!(indication_in %in% c('VALUE', 'COMPARATIVE_PRICE'))) {
  		
  		warning("Ignoring details, they are not available for indication ", indication_in,".")
  		
  		path <- relative_url$relativeUrl
  		
  	} else {
  		
  		path <- paste0(relative_url$relativeUrl,"?details=true")
  		
  	}
  	
  }
  
  if (metrics) {

  		path <- paste0(relative_url$relativeUrl,"?modelMetrics=true")

  }
  

  if (market_stats) {
  	
  	if (!(indication_in %in% c('COMPARATIVE_VALUE'))) {
  		
  		warning("Ignoring market_stats, they are not available for indication ", indication_in,".")
  		
  	} else {
  		
  		path <- paste0(path,ifelse(metrics,"&","?"), "marketStats=true")
  		
  	}
  	
  }

  if (!is.null(comparables)) {
  	
  	if (!(indication_in %in% c('COMPARATIVE_VALUE'))) {
  		
  		warning("Ignoring comparables, they are not available for indication ", indication_in,".")
  		
  	} else {
  		
  		path <- paste0(path,ifelse(market_stats | metrics,"&","?"),"comparables=",comparables)
  		
  	}
  	
  }
  
  response <- avm_response(path = path, type = 'POST', json = json)
  
  response
  
}


