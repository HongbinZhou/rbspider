require_relative "../parser/netease_news_parser"

ret = NeteaseNewsParser.on("http://news.163.com/14/1204/11/ACK99GE400014JB5.html")
puts ret.validate
puts ret[:title]
puts ret[:emotion_score]
