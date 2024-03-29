#' @title Structured AVM class
#'
#' @description This class extends existing classes to provide a unique and structured response from AVM API requests.
#'
#' @slot content A list containing response content.
#' @slot values A data.frame holding the requested data in wide format.
#' @slot ranges A data.frame holding the requested ranges if available in wide format.
#' @slot metrics A data.frame holding metrics data if available in wide format.
#' @slot details A data.frame holding details data if available in wide format.
#' @slot path A character with URL path of request.
#' @slot response An object of class `response`, which inlcudes the entire response from request.
#' @slot status An object of class `integer` including \code{status_code} of repsonse.
#'
#' @name avm_class
#' @rdname avm_class
#' @keywords internal

setOldClass("response")
setClass("avm_class",
				 representation(content = "list",
				 							 values = "data.frame",
				 							 trends = "data.frame",
				 							 metrics = "data.frame",
				 							 details = "data.frame",
				 							 path = "character",
				 							 response = "response",
				 							 status = "integer"))

