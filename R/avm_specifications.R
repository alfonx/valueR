#' @title Specifications from AVM API
#'
#' @description Function to receive information on valid specifications of AVM API. 
#'
#' @details 
#' It returns a list of data frames with all input parameters including input categories 
#' and all output paramaters including information on JSON output.
#' Columns with example, minimal or maximal values might also contain dates, that's why they return characters. 
#'
#' @seealso \code{\link{avm_response}}, \code{\link{avm_indications}}, \code{\link{avm_segments}}
#' @importFrom foreach %do%
#' @param indication A vector of indication endpoints. See also \code{\link{avm_indications}} to get all valid endpoints. 
#' @param segments A vector of segments. See also \code{\link{avm_segments}} to get all valid segments.
#' @param language Specification of english or german language used to format character columns with englisch settings as DEFAULT. If set to `DE`, big (`.`) and decimal (`,`) marks will be set and dates to `dd.mm.yyy`.
#' @format An object of class \code{list()} including \code{data.frames}
#' @export


avm_specifications <- function(indication = NULL,
                               segments = NULL,
															 language = c('EN','DE')) {
	
	language <- match.arg(language)
	
	oo <- options("scipen")
	options(scipen = 999)
	on.exit(options(scipen = oo))
	
	ep <- avm_indications()

  if (!all(indication %in% unique(ep$indication))) stop("You asked for unknown indication", call. = FALSE)

  if (is.null(indication)) {
    
  	indication <- unique(ep$indication)
  
  	}

  # get inputParameters


  param <- list()

  foreach::foreach(i = ep$relativeUrl, .combine = "c") %do% {

    ep_name <- ep$indication[ep$relativeUrl == i]

    param[[ep_name]] <- avm_response(path = paste0(i, "/specification"))
  
    }

  input <- foreach::foreach(e = unique(ep$indication), .combine = dplyr::bind_rows) %do% {
    
  	foreach::foreach(s = param[[e]]$content$segments, .combine = dplyr::bind_rows) %do% {
      
  		input_orig <- as.data.frame(param[[e]]$content$inputParameters[s]) %>%
        dplyr::rename_all(~ stringr::str_replace(., paste0(s, "."), "")) %>%
        dplyr::mutate(minValue = {if ("minValue" %in% names(.)) as.character(minValue) else NA}) %>% 
  			dplyr::mutate(maxValue = {if ("minValue" %in% names(.)) as.character(maxValue) else NA})

      input <- input_orig %>%
        dplyr::mutate(segment = s, endpoint = e) %>%
        dplyr::select(endpoint, segment, colnames(input_orig))
    
      }
  
  }
  
  output <- foreach::foreach(e = unique(ep$indication), .combine = dplyr::bind_rows) %do% {
    
  	output_orig <- as.data.frame(param[[e]]$content$outputParameters) %>%
      dplyr::mutate(exampleValue = {if ("exampleValue" %in% names(.)) as.character(exampleValue) else NA})

    output <- output_orig %>%
      dplyr::mutate(endpoint = e) %>%
      dplyr::select(endpoint, colnames(output_orig))
  
    }

  categories <- foreach::foreach(e = unique(ep$indication), .combine = dplyr::bind_rows) %do% {
    
  	foreach::foreach(s = unique(input$segment), .combine = dplyr::bind_rows) %do% {
      
  		foreach::foreach(c = unique(input$parameter[input$type == "category"]), .combine = dplyr::bind_rows) %do% {
        
  			categories <- data.frame(input$categories[input$parameter == c & input$endpoint == e & input$segment == s][1])
        categories_param <- categories %>% dplyr::mutate(parameter = c)
        categories_param <- categories_param %>%
          dplyr::mutate(segment = s, endpoint = e) %>%
          dplyr::select(endpoint, segment, parameter, colnames(categories))
      
        }
    
  		}
  
  	}

  json <- foreach::foreach(e = unique(ep$indication), .combine = dplyr::bind_rows) %do% {
    
  	foreach::foreach(c = unique(output$parameter[output$type == "json" & 
  																							 	!is.na(output$additionalHints) & 
  																							 	output$endpoint == e]), .combine = dplyr::bind_rows) %do% {
      
  		json_orig <- data.frame(jsonlite::fromJSON(output$additionalHints[output$parameter == c][1])) %>%
        dplyr::mutate(parameter = c)

      json <- json_orig %>%
        dplyr::mutate(endpoint = e) %>%
        dplyr::select(endpoint, parameter, colnames(json_orig))
    
      }
  
  	}

  if (is.null(segments)) {
    
  	segments <- unique(input$segment)
  
  }
  
  input <- input %>% dplyr::mutate(minValue = suppressWarnings(convert(minValue,parameter, language)),
  													maxValue = suppressWarnings(convert(maxValue,parameter, language)))
  
  inputParameters <- input %>% dplyr::filter(endpoint %in% indication & segment %in% segments)
  inputCategories <- categories %>% dplyr::filter(endpoint %in% indication & segment %in% segments)
  outputParameters <- output %>% dplyr::filter(endpoint %in% indication)
  outputJSON <- json %>% dplyr::filter(endpoint %in% indication)

  structure(
  	list(
  		inputParameters = inputParameters,
  		inputCategories = inputCategories,
  		outputParameters = outputParameters,
  		outputJSON = outputJSON
  	),
  	class = "avm_spec"
  )


  }



print.avm_specifications <- function(x, ...) {
	
	utils::str(x, max=1)
	invisible(x)
	
}


convert <- function(column, parameter, language = c('EN','DE')) {
	
	match.arg(language)
	
	if (language == 'DE') {
		
		date <- '%d.%m.%Y'
		dm <- ","
		bm <- "."
	
	} else if (language == 'EN') {
			
		date <- '%Y-%m-%d'
		dm <- "."
		bm <- ","
		
		}
	
	dplyr::na_if(ifelse(!is.na(as.Date(as.character(column), format = '%Y-%m-%d')) == T,
										as.character(format(as.Date(as.character(column), format = '%Y-%m-%d'), date)),
										ifelse(startsWith(parameter, "year"),
													 as.character(prettyNum(as.numeric(column))),
													 as.character(prettyNum(as.numeric(column), decimal.mark = dm, big.mark = bm)))),'NA')
	
}

