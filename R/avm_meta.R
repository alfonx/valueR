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

avm_indications <- function() {
  
  
  if (is.null(valuer$avm_indications)) {
  
  endpoints <- avm_response(path = "indicate/endpoints")

  df_gather <- endpoints$values

  license_status <- foreach::foreach(e = unique(df_gather$relativeUrl), .combine = dplyr::bind_rows) %do% {
      
      get_license <- avm_response(path = e, type = 'HEAD')
      
      license <- data.frame(relativeUrl = e,
                            accessGranted = ifelse(get_license$response$status_code == 204, TRUE, FALSE)) 
      
    }
    
  df_gather <- df_gather %>% 
    dplyr::left_join(license_status, by = c('relativeUrl')) %>%
    dplyr::filter(accessGranted == TRUE)
  
  assign('avm_indications', df_gather, valuer)
  
  } else {
    
    df_gather <- valuer$avm_indications
    
  }
  
  df_gather

}

#' @describeIn avm_meta Get information on all AVM endpoints.
#' @export

avm_indications_all <- function() {
  
    endpoints <- avm_response(path = "indicate/endpoints")
    
    df_gather <- endpoints$values
    
    license_status <- foreach::foreach(e = unique(df_gather$relativeUrl), .combine = dplyr::bind_rows) %do% {
      
      get_license <- avm_response(path = e, type = 'HEAD')
      
      license <- data.frame(relativeUrl = e,
                            accessGranted = ifelse(get_license$response$status_code == 204, TRUE, FALSE)) 
      
    }
    
    df_gather <- df_gather %>% dplyr::left_join(license_status, by = c('relativeUrl'))
    
  df_gather
  
}

#' @describeIn avm_meta Get segments by AVM endpoint.
#' @export

avm_segments <- function() {

  ep <- avm_indications()

  segments <- foreach::foreach(e = unique(ep$relativeUrl), .combine = dplyr::bind_rows) %do% {

    segs <- data.frame(segment = avm_response(path = paste0(e,"/specification?listOnlySegments=true"))$content$segments) %>%
      dplyr::mutate(endpoint = ep$indication[ep$relativeUrl == e]) %>% dplyr::select(endpoint, segment)

  }
  
  segments

}

