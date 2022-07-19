# set package environment

valuer <- new.env(parent = emptyenv())
assign('avm_status', 0, valuer)
assign('analyst_status', 0, valuer)

#' @title Set up connection to ANALYST and AVM
#'
#' @description Using \code{valuer_access()} you can connect to any valid and licensed API from VALUE Marktdaten.
#'
#' @section Note: You must have a valid license.
#' 
#' @seealso \code{\link{avm_response}}, \code{\link[httr:GET]{httr::GET()}}
#' @param avm_url A valid url from which you want to access our AVM with Sys.getenv("VALUER_AVM_URL") as default.
#' @param avm_username A character vector for username with Sys.getenv("VALUER_AVM_USER") as default.
#' @param avm_password A character vector for password with Sys.getenv("VALUER_AVM_PW") as default.
#' @param analyst_url A valid url from which you want to access our AVM with Sys.getenv("VALUER_ANALYST_URL") as default.
#' @param analyst_username A character vector for username with Sys.getenv("VALUER_ANALYST_USER") as default.
#' @param analyst_password A character vector for password with Sys.getenv("VALUER_ANALYST_PW") as default.
#' @examples \dontrun{valuer_access()}
#' @export

valuer_access <- function(avm_url = Sys.getenv("VALUER_AVM_URL"),
													avm_username = Sys.getenv("VALUER_AVM_USER"),
													avm_password = Sys.getenv("VALUER_AVM_PW"),
													analyst_url = Sys.getenv("VALUER_ANALYST_URL"),
													analyst_username = Sys.getenv("VALUER_ANALYST_USER"),
													analyst_password = Sys.getenv("VALUER_ANALYST_PW")) {
  
  if (is.null(avm_username) | avm_username == "") message("You must provide a non-empty avm_username to connect.")
  if (is.null(avm_password) | avm_password == "") message("You must provide a non-empty avm_password to connect.")
	if (is.null(avm_url) | avm_url == "") message("You must provide a non-empty avm_url to connect.")

	if (is.null(analyst_username) | analyst_username == "") message("You must provide a non-empty analyst_username to connect.")
	if (is.null(analyst_password) | analyst_password == "") message("You must provide a non-empty analyst_password to connect.")
	if (is.null(analyst_url) | analyst_url == "") message("You must provide a non-empty analyst_url to connect.")
	
  assign('avm_password', avm_password, valuer)
  assign('avm_username', avm_username, valuer)

  assign('analyst_password', analyst_password, valuer)
  assign('analyst_username', analyst_username, valuer)
  
  # AVM

  tryCatch(
  	{
  		assign('avmurl', httr::modify_url(avm_url), valuer)
  		assign('avm_status', 200, valuer)
  		avm_status <- avm_response(path = "status")
  		assign('avm_status', httr::status_code(avm_status$response), valuer)
  		if (httr::status_code(avm_status$response) == 200) message("Connected to AVM: ", valuer$avmurl)
  	},
  	error=function(e) {
  		message("Unable to connect to AVM.")
  	})
  
  
  # API
  
  tryCatch(
  	{
  		assign('analyst_url', httr::modify_url(analyst_url), valuer)
  		assign('analyst_status', 200, valuer)
  		analyst_status <- analyst_response(path = "status")
  		assign('analyst_status', httr::status_code(analyst_status$response), valuer)
  		if (httr::status_code(analyst_status$response) == 200) message("Connected to API: ", valuer$analyst_url)
   	},
  	error=function(e) {
  		message("Unable to connect to ANALYST.")
  	})
  
  

  
  # reset avm_indications to get right specifications, see avm_indications()
  
  valuer$avm_indications <- NULL
  invisible(avm_indications())

  invisible(NULL)
  
 }


