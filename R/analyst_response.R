#' @title Requests from API
#'
#' @description Functions to set up requests from VALUE marketdata API.
#'
#' @details These (internal) functions are helpers to start ANALYST-API requests. 
#' They require valid credentials to access VALUE Marktdaten API. 
#' See \code{\link{valuer_access}} to set up access.
#' 
#' @section Note:
#' \code{\link[httr:content]{httr::content()}} will use `UTF-8` for encoding.
#'
#' @seealso \code{\link[httr:GET]{httr::GET()}}, \code{\link[httr:POST]{httr::POST()}}
#' @param path Path to the desired endpoint.
#' @param type One of GET, POST or HEAD.
#' @param json Request body in JSON format.
#' @returns An object of class \code{\link{list}}.
#' @examples \dontrun{analyst_response(path = "status")}
#' @export

analyst_response <- function(path = NULL, type = c("GET", "POST", "HEAD"), json = NULL) {
  
  type <- rlang::arg_match(type)
  
  if (is.null(path)) stop("You must specify a path.", call. = FALSE)
  if (valuer$analyst_status != 200) stop("No valid connection to ANALYST has been initialized. Run valuer_access().", call. = FALSE)

  # if (type == "POST" && (is.null(json) || jsonlite::validate(json) == FALSE)) stop("You must specify a valid json.", call. = FALSE)
  
  url <- httr::modify_url(valuer$analyst_url, path = path)  
  
  if (type == "GET") {
    
  resp <- httr::GET(url,
                    encode = "json",
                    httr::authenticate(user = valuer$analyst_username, 
                                       password = valuer$analyst_password, 
                                       type = "basic"))
  
  parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = 'UTF-8'))

  if (httr::http_type(resp) != "application/json") {stop("API did not return json", call. = FALSE)}
  
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "API request failed [%s] <%s>",
        httr::status_code(resp),
        parsed$error
      ),
      call. = FALSE
    )
  }
  
  values <- tryCatch(
    {
    	df <- data.frame(parsed) 
    	df <- df %>% tidyr::unnest(., col = c(colnames(df))) 
    	df <- df %>% tidyr::unnest(., col = c(colnames(df))) 
    	df <- df %>% tidyr::unnest(., col = c(colnames(df))) 
      
    	df <- df %>% dplyr::rename_all(~ stringr::str_replace(., ".*(?=\\.).", "")) %>%
    		dplyr::select(-dplyr::contains('durationMillis'))
    	
    	}, error = function(e){NULL})
  

  } else if (type == "HEAD") {
    
    resp <- httr::HEAD(url,
                       encode = "json",
                       httr::authenticate(user = valuer$analyst_username, 
                                          password = valuer$analyst_password, 
                                          type = "basic"))
    
    parsed <- NULL
  

  } else if (type == "POST") {
    
    resp <- httr::POST(url,
                       body = jsonlite::fromJSON(paste0(json)),
                       encode = "json",
                       httr::authenticate(user = valuer$analyst_username, 
                                          password = valuer$analyst_password, 
                                          type = "basic"))
    
    parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = 'UTF-8'))
    
    if (httr::http_type(resp) != "application/json") {stop("API did not return json", call. = FALSE)}
    
    if (httr::http_error(resp)) {
      stop(
        sprintf(
          "API request failed [%s] <%s>",
          httr::status_code(resp),
          parsed$error
        ),
        call. = FALSE
      )
    }
    
    
    values <- tryCatch(
      {
        data.frame(parsed) %>%
          dplyr::select(-durationMillis)
      }, error = function(e){NULL})
    
  }
  
  structure(
    list(
    	values = values %>% data.frame(),
    	json = NULL,
    	path = path,
    	content = parsed,
      response = resp
    ),
    comment = "Structured response from any ANALYST-API request including tidy data."
  )
    
}


