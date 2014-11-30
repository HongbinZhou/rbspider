#!/usr/bin/ruby

require "spidr"
require 'nokogiri'
require 'open-uri'
require 'time'
require_relative 'parser/news_parser'
require_relative "database/news_db"

include NewsDB

def news_url_to_news(url)
  parser_result = NewsParser.new(url)
  {
    title: parser_result.news_title,
    category: parser_result.news_category,
    pub_date: parser_result.news_pub_date,
    from_site: parser_result.news_from_site,
    image: parser_result.news_image.join(" "),
    video: parser_result.news_video,
    text: parser_result.news_text
  }
end

# ++
# main
# ++

$VERBOSE = nil

Spidr.site('http://news.163.com/') do |spider|
  spider.every_page do |page|
    #puts "[-] #{page.url} :  #{page.content_type} : #{page.title}"
    if page.url.to_s =~ /html$/
      save_news(news_url_to_news(page.url.to_s))
    end
  end
end
