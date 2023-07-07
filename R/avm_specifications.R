#' @title Specifications from AVM API
#'
#' @description Function to receive information on valid specifications of AVM API. 
#'
#' @details 
#' It returns a list of data frames with all input parameters including input categories 
#' and all output paramaters including information on JSON output.
#' Columns with example, minimal or maximal values might also contain dates, that's why they return characters. 
#'
#' @seealso \code{\link{avm_response}}, \code{\link{avm_endpoints}}, \code{\link{avm_segments}}
#' @importFrom foreach %do%
#' @param endpoint A vector of indication endpoints with \code{specification = T}. See also \code{\link{avm_endpoints}} to get all valid endpoints. 
#' @param segments A vector of segments. See also \code{\link{avm_segments}} to get all valid segments.
#' @param language Specification of english or german language used to format character columns with englisch settings as DEFAULT. If set to `DE`, big (`.`) and decimal (`,`) marks will be set and dates to `dd.mm.yyy`.
#' @format An object of class \code{list()} including \code{data.frames}
#' @export
#' 

avm_specifications <- function(endpoint = NULL,
															 segments = NULL,
															 language = c('EN','DE')) {
	
	language <- match.arg(language)
	
	oo <- options("scipen")
	options(scipen = 999)
	on.exit(options(scipen = oo))
	
	ep <- avm_endpoints() %>% dplyr::filter(specification == T)

  if (!all(endpoint %in% unique(ep$endpoint))) stop("You asked for an unknown endpoint", call. = FALSE)

  ep_in <- if (is.null(endpoint)) unique(ep$endpoint) else endpoint

  # get inputParameters

  param <- list()

  foreach::foreach(i = ep$relativeUrl, .combine = "c") %do% {
    ep_name <- ep$endpoint[ep$relativeUrl == i]
    param[[ep_name]] <- avm_response(path = paste0(i, "/specification"))
  }
  

  input <- foreach::foreach(e = unique(ep$endpoint), .combine = dplyr::bind_rows) %do% {
  	foreach::foreach(s = param[[e]]$content$segments, .combine = dplyr::bind_rows) %do% {
 		if (is.null(s)) {
  			input <- data.frame()
  		} else {
  			input_orig <- as.data.frame(param[[e]]$content$inputParameters[s]) %>%
        	dplyr::rename_all(~ stringr::str_replace(., paste0(s, "."), "")) %>%
        	dplyr::mutate(minValue = {if ("minValue" %in% names(.)) as.character(minValue) else NA}) %>% 
  				dplyr::mutate(maxValue = {if ("maxValue" %in% names(.)) as.character(maxValue) else NA}) %>%
  				dplyr::mutate(exampleValue = {if ("exampleValue" %in% names(.)) as.character(exampleValue) else NA})

      		input <- input_orig %>%
        		dplyr::mutate(segment = s, endpoint = e) %>%
        		dplyr::select(endpoint, segment, colnames(input_orig))
  		}
  	}
  }
  
  segments <- if (is.null(segments)) unique(input$segment) else segments
  

  output <- foreach::foreach(e = unique(ep$endpoint), .combine = dplyr::bind_rows) %do% {
  	output_orig <- as.data.frame(param[[e]]$content$outputParameters)
  	output_orig <- output_orig %>%
  		dplyr::mutate(exampleValue = {if (class(output_orig$exampleValue) == "data.frame") as.character(jsonlite::toJSON(exampleValue)) else exampleValue}) %>% 
      dplyr::mutate(exampleValue = {if ("exampleValue" %in% names(.)) as.character(exampleValue) else NA})
   output <- output_orig %>%
      dplyr::mutate(endpoint = e) %>%
      dplyr::select(endpoint, colnames(output_orig))
  
    }

  categories <- foreach::foreach(e = unique(ep$endpoint), .combine = dplyr::bind_rows) %do% {
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

  out_categories <- foreach::foreach(e = unique(ep$endpoint), .combine = dplyr::bind_rows) %do% {
  		foreach::foreach(c = unique(output$parameter[output$type == "category"]), .combine = dplyr::bind_rows) %do% {
  			out_categories <- data.frame(output$categories[output$parameter == c & output$endpoint == e][1])
  			out_categories_param <- out_categories %>% dplyr::mutate(parameter = c)
  			out_categories_param <- out_categories_param %>%
  				dplyr::mutate(endpoint = e) %>%
  				dplyr::select(endpoint, parameter, colnames(out_categories))
  	}
  }
  
  json <- suppressWarnings(foreach::foreach(e = unique(ep$endpoint), .combine = dplyr::bind_rows) %do% {
  					foreach::foreach(c = unique(output$parameter[output$type == "json" & output$endpoint == e]),
  													 .combine = dplyr::bind_rows) %do% {
  		if (is.null(c)) {
  			json <- data.frame()
  		} else {
  		
  		json_orig <- output %>% dplyr::filter(parameter == c) %>% 
  			dplyr::select(model) %>% 
  			tidyr::unnest(cols = c(model)) %>%
  			dplyr::select(properties) %>% 
  			tidyr::unnest(cols = c(properties)) %>%
  			dplyr::mutate(exampleValue = {if ("exampleValue" %in% names(.)) as.character(exampleValue) else NA}) %>%
  			dplyr::mutate_if(is.logical, as.character)
  		
  		json <- json_orig %>%
        dplyr::mutate(endpoint = e, parameter = c) %>%
        dplyr::select(endpoint, parameter, colnames(json_orig))
  		
  		i <- 0
  		
			if ('json' %in% json$type) {
				
			repeat {

				p <- unique(json$property[json$type == "json" & !is.na(json$model)])
				i <- i + 1

				json_orig_model <- json %>% dplyr::filter(property == p[i]) %>%
					dplyr::select(model) %>%
					tidyr::unnest(cols = c(model)) %>%
					dplyr::select(properties) %>%
					tidyr::unnest(cols = c(properties)) %>%
					dplyr::mutate(exampleValue = {if ("exampleValue" %in% names(.)) as.character(exampleValue) else NA}) %>%
					dplyr::mutate_if(is.logical, as.character)

				json_model <- json_orig_model %>%
					dplyr::mutate(endpoint = e, parameter = p[i]) %>%
					dplyr::select(endpoint, parameter, colnames(json_orig_model)) %>%
					dplyr::mutate(key = T)

				json <- json %>% dplyr::bind_rows(json_model)

				# if (all(json$property[json$type == 'json'] %in% json$parameter)) break
				if (i == 10) break

			}

			}

  		json <- json %>% dplyr::distinct(.keep_all = T)
			return(json)

			}

  		}
			
  }
			
  )

			json <- json %>% dplyr::select(-model)
			
			json_cat <- foreach::foreach(e = unique(ep$endpoint), .combine = dplyr::bind_rows) %do% {
					foreach::foreach(c = unique(json$property[json$type == "category"]), .combine = dplyr::bind_rows) %do% {
						j_categories <- data.frame(json$categories[json$property == c & json$endpoint == e][1])
						j_categories_param <- j_categories %>% dplyr::mutate(property = c)
						j_categories_param <- j_categories_param %>%
							dplyr::mutate(endpoint = e) %>%
							dplyr::select(endpoint, property, colnames(j_categories))
				}
			}
			


  input <- input %>% dplyr::mutate(minValue = suppressWarnings(convert(minValue,parameter, language)),
  													maxValue = suppressWarnings(convert(maxValue,parameter, language)))
  
  inputParameters <- input %>% dplyr::filter(endpoint %in% ep_in & segment %in% segments)
  inputCategories <- categories %>% dplyr::filter(endpoint %in% ep_in & segment %in% segments)
  outputParameters <- output %>% dplyr::filter(endpoint %in% ep_in)
  outputJSON <- json %>% dplyr::filter(endpoint %in% ep_in)
  outputCategories <- out_categories %>% dplyr::filter(endpoint %in% ep_in)
  outputJSONCategories <- json_cat %>% dplyr::filter(endpoint %in% ep_in)
  
  structure(
  	list(
  		inputParameters = inputParameters,
  		inputCategories = inputCategories,
  		outputParameters = outputParameters,
  		outputJSON = outputJSON,
  		outputCategories = outputCategories,
  		outputJSONCategories = outputJSONCategories 
  	))


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

