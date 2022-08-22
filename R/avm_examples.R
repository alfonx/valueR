#' @title Example values from AVM API
#'
#' @description Get example values from example requests.
#' 
#' @details Based on provided exampleRequests, you will get all output values.
#' These values contain several formats such as numbers or dates. 
#' To provide a unique column, we decided to transform all values into characters. 
#'
#' @seealso \code{\link{avm_response}}
#' 
#' @importFrom foreach %do%
#' @returns An object of class \code{data.frame}.
#' 
#' @examples \dontrun{avm_examples()}
#' @export

avm_examples <- function(){

	oo <- options("scipen")
	options(scipen = 999)
	on.exit(options(scipen = oo))
	
	ep <- avm_indications()
	
	example_values <- foreach::foreach(i = unique(ep$relativeUrl), .combine = dplyr::bind_rows) %do% {

		# i <- "/objectInformation"
		
		path <- if (i == "/indicate/comparativeValue") paste0(i,"?marketStats=true&comparables=BESTCOORDS") else i
		
		i_resp <- avm_response(path = paste0(i, "/specification"))
		response <- i_resp[["response"]]
		request <- httr::content(response, as = "parsed")
		json <- jsonlite::toJSON(request[["exampleRequest"]], auto_unbox  = T)

		# jsono <- jsonlite::fromJSON(json)
		# jsono$address <- NULL
		# 
		# json <- jsonlite::toJSON(jsono)
		
		# resp <- httr::POST("https://avm-api-stage.value-marktdaten.de/v1/objectInformation",
		# 									 body = jsonlite::fromJSON(json, simplifyVector = F),
		# 									 encode = "json",
		# 									 httr::authenticate(user = Sys.getenv("VALUER_AVM_USER"), 
		# 									 									 password = Sys.getenv("VALUER_AVM_PW"), 
		# 									 									 type = "basic"))
		
		
		p_resp <- avm_response(path = path, type = 'POST', json = json)
		
		ename <- ep[["indication"]][ep[["relativeUrl"]] == i]
		
		parsed <- jsonlite::fromJSON(httr::content(p_resp$response, "text", encoding = 'UTF-8'))
		
		example_values <- parsed %>% tibble::enframe() %>% 
			dplyr::rowwise() %>%
			dplyr::mutate(indication = ename,
										exampleValue = ifelse(is.list(value), jsonlite::toJSON(value, auto_unbox = T), as.character(value)),
										outputParameter = name) %>%
			dplyr::select(indication,exampleValue, outputParameter)
	
	}
	
	example_values
	
}

