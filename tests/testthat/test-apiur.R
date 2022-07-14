test_that("standards", {
  
	expect_equal(nrow(avm_segments()), 18)
	expect_equal(nrow(avm_indications()), 7)

	specs <- avm_specifications()	
	
	expect_gt(lengths(specs[specs = "inputParameters"]),1)
	expect_gt(lengths(specs[specs = "outputParameters"]),1)
	expect_gt(lengths(specs[specs = "inputCategories"]),1)
	# expect_gt(lengths(specs[specs = "outputJSON"]),1)
	
	json <- '{
	"address": "Heidestraße 8, 10557 Berlin",
  "segment": "WHG_K",
  "space_living": 100,
  "year_of_construction": 1990,
  "quality_furnishings": 1
}'
	
	test <- apiur::avm(indication = 'COMPARATIVE_VALUE', json = json, market_stats = T, comparables = 'BESTCOORDS', metrics = T)
	
	
	expect_s3_class(test$values,"data.frame")
	expect_s3_class(test$market_stats_timeline,"data.frame")
	expect_s3_class(test$comparables,"data.frame")
	
	expect_gt(nrow(test$comparables),0)
	expect_gt(nrow(test$market_stats_timeline),0)
	expect_gt(nrow(test$market_stats_timeline_rent),0)
	expect_gt(nrow(test$market_stats_offer_price_range),0)
	expect_gt(nrow(test$market_stats_quality_ranges),0)
	
})
