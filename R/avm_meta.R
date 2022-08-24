#' @title Meta data from AVM API
#'
#' @description Functions to receive meta data from AVM API.
#'
#' @name avm_meta
#' @seealso \code{\link{avm_response}}
#' @importFrom foreach %do%
#' @return An object of class \code{data.frame}.
#' @section Examples:
#' ```{r}
#' #colnames(avm.endpoints())
#' ```
#' @md
NULL

#' @describeIn avm_meta Get information on AVM status.
#' @export

avm_status <- function() {

  status <- avm_response(path = "status")

  df_gather <- status$values
  
  df_gather

}

#' @describeIn avm_meta Get information on AVM endpoints with access granted.
#' @export

avm_endpoints <- function() {
  
  
  if (is.null(valuer$avm_endpoints)) {
  
  
  	resp <- httr::GET(paste0(valuer$avmurl, "/openapi.json"),
  										encode = "json",
  										httr::authenticate(user = valuer$avm_username, 
  																			 password = valuer$avm_password, 
  																			 type = "basic"))
  	
  	parsed <- tryCatch({jsonlite::fromJSON(httr::content(resp, "text", encoding = 'UTF-8'))}, error = function(e){NULL})
  	
  	values <- parsed$paths %>% 
  		tibble::enframe() %>% 
  		data.frame() %>%
  		tidyr::unnest_longer(value) %>% 
  		tidyr::unnest(colnames(.)) %>%
  		dplyr::mutate(val = as.character(value)) %>%
  		dplyr::select(val, relativeUrl = name, type = value_id)
  	
  	endpoints <- parsed$tags %>% dplyr::left_join(values, by = c("name" = "val")) %>% dplyr::filter(type != 'head')
  	
  	specs <- endpoints %>% dplyr::filter(stringr::str_detect(relativeUrl, 'specification')) %>% dplyr::mutate(specification = T) %>% dplyr::select(specification, name)
  	
  	endpoints <- endpoints %>% 
  		dplyr::filter(!stringr::str_detect(relativeUrl, 'specification|documentation|legend')) %>% 
  		dplyr::mutate(key = toupper(snakecase::to_any_case(gsub("/","",gsub("/indicate/", "", relativeUrl))))) %>%
  		dplyr::left_join(specs, by = c("name"))
  	

  license_status <- foreach::foreach(e = unique(endpoints$relativeUrl), .combine = dplyr::bind_rows) %do% {
  	
      get_license <- avm_response(path = e, type = 'HEAD')
      
      license <- data.frame(relativeUrl = e,
                            accessGranted = ifelse(get_license$response$status_code %in% c(200,204), TRUE, FALSE)) 
      
    }
    
  endpoints_full <- endpoints %>%
  	dplyr::left_join(license_status, by = c('relativeUrl')) %>%
  	dplyr::select(endpoint = key, name, relativeUrl, specification, accessGranted, description) %>%
  	dplyr::filter(endpoint != 'GEOREFS')
  
  assign('avm_endpoints', endpoints_full, valuer)
  
  } else {
    
  	endpoints_full <- valuer$avm_endpoints
    
  }
  
  return(endpoints_full)

}


#' @describeIn avm_meta Get segments by AVM endpoint.
#' @export

avm_segments <- function() {

  ep <- avm_endpoints() %>% dplyr::filter(!is.na(specification))

  segments <- foreach::foreach(e = unique(ep$relativeUrl), .combine = dplyr::bind_rows) %do% {

    segs <- data.frame(segment = avm_response(path = paste0(e,"/specification?listOnlySegments=true"))$content$segments) %>%
      dplyr::mutate(endpoint = ep$endpoint[ep$relativeUrl == e]) %>% dplyr::select(endpoint, segment)

  }
  
  segments

}

