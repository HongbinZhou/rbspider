require_relative "sentiment_analysis"

a = SentimentText.new("乱七八糟的杀人")
puts a.words
puts a.sentiment_score
