#!/usr/bin/ruby

require "spidr"
require 'nokogiri'
require 'open-uri'
require 'time'
require_relative 'parser/netease_news_parser'
require_relative "database/db_engine"

# ++
# main
# ++

$VERBOSE = nil

Spidr.site('http://news.163.com/') do |spider|
  spider.every_page do |page|
    #puts "[-] #{page.url} :  #{page.content_type} : #{page.title}"
    puts page.url.to_s
    if page.url.to_s =~ /html$/
      puts page.url
      parser_result = NeteaseNewsParser.on(page.url.to_s)
      DatabaseEngine.save(parser_result)
    end
  end
end
