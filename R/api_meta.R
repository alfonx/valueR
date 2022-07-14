#' @title Meta data from API
#'
#' @description Functions to receive meta data from AVM API.
#'
#' @section Notes: This function assumes that environment variables `APIUR_USER`, `APIUR_PW` and a valid license exist.
#'
#' @name api_meta
#' @returns Each function returns an object of class \code{data.frame}.
#' @seealso \code{\link{api_response}}
#' @param var ID or KEY of the variable to show. 
#' See \href{https://api.value-marktdaten.de/api-docs/}{Swagger Documentation} for all IDs and KEYs available.
#' @param segment ID or KEY of the market-segment to show. If specified together with `categories`, categories of the segment only are shown. 
#' See \href{https://api.value-marktdaten.de/api-docs/}{Swagger Documentation} for all IDs and KEYs available.
#' @param categories If TRUE, categories of variable are shown. If TRUE, a `var` of type categorie is required. 
#' @param type Type of spatial unit, one of \code{c("districts", "municipalities", "localities", "states", "u1", "u2", "u3")}.
#' Defaults to `districts`.
#' @param code Either a `municipality code` for type `municipalities` or a district code for type `districts`.
#' Will be ignored for other input in `type`.
#' @param details_state If TRUE, details about the state are included in results for municipalities and districts.
#' @param details_district If TRUE, details about the district are included in results for municipalities.
#' @examples \dontrun{pdf_docs(endpoint = 'MARKET_VALUE', deploy = TRUE)}
NULL

#' @describeIn api_meta Get information on API status.
#' @export

api_status <- function() {

  status <- api_response(path = "status")

  df <- status$values %>% dplyr::rename_all(~ stringr::str_replace(., "status.", ""))

  df

}


#' @describeIn api_meta Get information on API segments.
#' @export

api_segments <- function(segment = NULL) {
	
	seg_path <- paste0("segments",
										 ifelse(is.null(segment),"",paste0("/",segment)))
	
	segments <- api_response(path = seg_path)
	
	df <- segments$values %>% dplyr::rename_all(~ stringr::str_replace(., "segments.", ""))
	
	df
	
}

#' @describeIn api_meta Get information on API variables.
#' @export

api_vars <- function(var = NULL,
										 segment = NULL,
										 categories = FALSE) {
	
	if (categories & is.null(var)) stop("You must provide var to get categories.")
	
	var_path <- paste0("vars",
										 ifelse(is.null(var),"",paste0("/",var)),
										 ifelse(categories & is.null(segment), paste0("/categories"),""),
										 ifelse(categories & !is.null(segment),paste0("/categories?segment=",segment),""))
	
	
	vars <- api_response(path = var_path)
	
	df <- vars$values %>% 
		dplyr::rename_all(~ stringr::str_replace(., "vars.", "")) %>%
		dplyr::rename_all(~ stringr::str_replace(., "categories.", ""))
	
	df
	
}

#' @describeIn api_meta Get information on API spatial variables.
#' @export

api_spatial <- function(type = c("districts", "municipalities", "localities", "states", "u1", "u2", "u3"),
												code = NULL,
												details_state = FALSE,
												details_district = FALSE) {
	
	type <- match.arg(type)
	
	if (!(type %in% c("districts", "municipalities")) & !is.null(code)) {
		
		code <- NULL
		message("Ignoring 'code', it is not available for type ", type, ".")
		
	}

	spatial_path <- paste0("vars/spatial/",type, ifelse(!is.null(code),paste0("/",code),""))
	
	spatial_path <- if (details_state) paste0(spatial_path,"?showStateDetails=true") else spatial_path
	spatial_path <- if (details_district) paste0(spatial_path,"&showDistrictDetails=true") else spatial_path

	spatial <- api_response(path = spatial_path)
	
	df <- spatial$values %>% 
		dplyr::rename_all(~ stringr::str_replace(., paste0(type,"."), "")) 
	
	df
	
}



