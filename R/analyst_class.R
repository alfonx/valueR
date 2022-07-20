#' @title Structured ANALYST class
#'
#' @description This class extends existing classes to provide a unique and structured response from ANALYST API requests.
#'
#' @slot values A data.frame holding the requested data in wide format.
#' @slot json Any JSON as character. 
#' @slot path A character with URL path of request.
#' @slot content A list containing response content.
#' @slot response An object of class `response`, which inlcudes the entire response from request.
#'
#' @name analyst_class
#' @rdname analyst_class
#' @keywords internal

setOldClass("response")
setClass("analyst_class",
				 representation(
				 							 values = "data.frame",
				 							 json = "character",
				 							 path = "character",
				 							 content = "list",
				 							 response = "response"))

