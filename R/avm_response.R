#' @title Requests from AVM
#'
#' @description Functions to set up requests from VALUE market data AVM.
#'
#' @details This functions is a helper to start AVM requests. 
#' It requires valid credentials to access VALUE Marktdaten AVM API. 
#' See \code{\link{valuer_access}} to set up access.
#' 
#' @section Note:
#' \code{\link[httr:content]{httr::content()}} will use `UTF-8` for encoding. 
#' There is currentlly no option to change this.
#'
#' @seealso \code{\link[httr:GET]{httr::GET()}}, \code{\link[httr:POST]{httr::POST()}}
#' @param path Path to the desired endpoint.
#' @param type One of GET, POST or HEAD.
#' @param json Request body in JSON format.
#' @returns An object of class \code{\link{avm_class}}.
#' @examples \dontrun{avm_response(path = "status")}
#' @export

avm_response <- function(path = NULL, 
                         type = c("GET", "POST", "HEAD"), 
                         json = NULL) {
  
  type <- rlang::arg_match(type)
  
  if (is.null(path)) stop("You must specify a path.", call. = FALSE)
  if (valuer$avm_status != 200) stop("No valid connection to AVM has been initialized. Run valuer_access().", call. = FALSE)

  if (type == "POST" && (is.null(json) || jsonlite::validate(json) == FALSE)) stop("You must specify a valid json.", call. = FALSE)
  
  path <- if (!startsWith(path, "/")) paste0("/", path) else path

  url <- paste0(valuer$avmurl, path)
  
  if (type == "GET") {

  resp <- httr::GET(url,
                    encode = "json",
                    httr::authenticate(user = valuer$avm_username, 
                                       password = valuer$avm_password, 
                                       type = "basic"))
  
  status <- httr::status_code(resp)
  
  parsed <- tryCatch({jsonlite::fromJSON(httr::content(resp, "text", encoding = 'UTF-8'))}, error = function(e){NULL})
  
  # if (httr::http_type(resp) != "application/json") {stop("API did not return json", call. = FALSE)}
  
  values <- tryCatch(
    {
      data.frame(parsed) %>%
        dplyr::select(-dplyr::contains('durationMillis')) %>%
        dplyr::rename_all(~ stringr::str_replace(., "endpoints.", ""))
      }, error = function(e){NULL})
  
  trends <- NULL
  ranges <- NULL
  details <- NULL
  metrics <- NULL
  
  market_stats_timeline <- NULL
  market_stats_timeline_rent<- NULL
  market_stats_timeline_condominium <- NULL    
  market_stats_offer_price_range <- NULL
  market_stats_quality_classification <- NULL
  market_stats_quality_ranges <- NULL
  comparables <- NULL
  
  

  
  } else if (type == "HEAD") {
    
    resp <- httr::HEAD(url,
                       encode = "json",
                       httr::authenticate(user = valuer$avm_username, 
                                          password = valuer$avm_password, 
                                          type = "basic"))
    
    status <- httr::status_code(resp)
    
    
    
    parsed <- NULL
  
    values <- NULL
    trends <- NULL
    ranges <- NULL
    details <- NULL
    metrics <- NULL
    
    market_stats_timeline <- NULL
    market_stats_timeline_rent<- NULL
    market_stats_timeline_condominium <- NULL    
    market_stats_offer_price_range <- NULL
    market_stats_quality_classification <- NULL
    market_stats_quality_ranges <- NULL
    comparables <- NULL
    
    
  
  } else if (type == "POST") {
  	
    resp <- httr::POST(url,
                       body = jsonlite::fromJSON(paste0(json)),
                       encode = "json",
                       httr::authenticate(user = valuer$avm_username, 
                                          password = valuer$avm_password, 
                                          type = "basic"))
    
    status <- as.integer(httr::status_code(resp))
    
    if (status == 200) {
      
    content <- httr::content(resp, "text", encoding = 'UTF-8')
    parsed <- jsonlite::fromJSON(content)
    
    } else {
      
      parsed <- c()
    
      }

    values_enframe <- parsed %>% tibble::enframe()
    
    values <- values_enframe %>%
      dplyr::filter(lengths(value) == 1) %>%
      tidyr::pivot_wider(value) %>% tidyr::unnest(colnames(.))
    
    ranges <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"ranges")) %>%
      tidyr::unnest_longer(value) %>% tidyr::unnest(colnames(.))

    trends <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"_trend_local_time")) %>%
      tidyr::unnest_longer(value) %>% tidyr::unnest(colnames(.))

    details <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"_details")) %>%
      tidyr::unnest_wider(value) %>% 
    	dplyr::select(-tidyselect::contains("trend_local_time")) %>%
    	tidyr::unnest(colnames(.))

    metrics <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"model_metrics")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(-tidyselect::contains("region_geom")) %>%
      tidyr::unnest(colnames(.))
    
    market_stats_timeline <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"market_stats")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(tidyselect::ends_with("timeline")) %>%
      tidyr::unnest(colnames(.))

    market_stats_timeline_rent <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"market_stats")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(tidyselect::contains("timeline_rent")) %>%
      tidyr::unnest(colnames(.))

    market_stats_timeline_condominium <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"market_stats")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(tidyselect::contains("timeline_condominium")) %>%
      tidyr::unnest(colnames(.))
    
    market_stats_offer_price_range <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"market_stats")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(tidyselect::contains("offer_price_range")) %>%
      tidyr::unnest(colnames(.))
    
    market_stats_quality_classification <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"market_stats")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(tidyselect::contains("quality")) 
    
    market_stats_quality_classification <- if (length(market_stats_quality_classification) > 0)  market_stats_quality_classification %>% tidyr::unnest_wider(quality) %>% dplyr::select(tidyselect::contains("quality_classification"))

    market_stats_quality_ranges <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"market_stats")) %>%
      tidyr::unnest_wider(value) %>% dplyr::select(tidyselect::contains("quality")) 
    
    market_stats_quality_ranges <- if (length(market_stats_quality_ranges) > 0) market_stats_quality_ranges %>% tidyr::unnest_wider(quality) %>% dplyr::select(tidyselect::contains("quality_ranges")) %>% tidyr::unnest(colnames(.))
    
    comparables <- values_enframe %>%
      dplyr::filter(stringr::str_detect(name,"comparables")) %>%
      tidyr::unnest_wider(value) %>% tidyr::unnest(colnames(.))
    
    
  }
  
    structure(
      list(
        content = parsed,
        values = values %>% data.frame(),
        ranges = ranges %>% data.frame(),
        trends = trends %>% data.frame(),
        metrics = metrics %>% data.frame(),
        details = details %>% data.frame(),
        market_stats_timeline = market_stats_timeline %>% data.frame(),
        market_stats_timeline_rent = market_stats_timeline_rent %>% data.frame(),
        market_stats_timeline_condominium = market_stats_timeline_condominium %>% data.frame(),
        market_stats_offer_price_range = market_stats_offer_price_range %>% data.frame(),
        market_stats_quality_classification = market_stats_quality_classification %>% data.frame(),
        market_stats_quality_ranges = market_stats_quality_ranges %>% data.frame(),
        comparables = comparables %>% data.frame(),
        path = path,
        response = resp,
        status = status
      ),
      class = "avm_class",
      comment = "Structured response from API AVM request including tidy data."
    )
    
}

