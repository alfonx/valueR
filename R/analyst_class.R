#' @title Structured ANALYST class
#'
#' @description This class extends existing classes to provide a unique and structured response from ANALYST API requests.
#'
#' @slot content A list containing response content.
#' @slot values A data.frame holding the requested data in wide format.
#' @slot path A character with URL path of request.
#' @slot response An object of class `response`, which inlcudes the entire response from request.
#'
#' @name api_class
#' @rdname api_class
#' @keywords internal

setOldClass("response")
setClass("analyst_class",
				 representation(content = "list",
				 							 values = "data.frame",
				 							 path = "character",
				 							 response = "response"))

