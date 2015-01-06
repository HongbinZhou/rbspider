# coding: utf-8

require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class SinaSportsParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    return nil if url !~ /\.s?html$/
    response = open(url)
    @doc = Nokogiri(response)
    
    news = NeteaseNewsParserResult.new
    news.database_to_save = "sina_sports_news.db"
    news.table_to_save    = "new"
    news[:title]          = news_title(url) # must
    news[:pub_date]       = news_pub_date(url) # must
    news[:text]           = news_text(url) # must
    news[:link]           = url            # must
    news[:image]          = news_image(url)
    if news.validate
      puts "#{url} valid!"
      news[:emotion_score] = SentimentText.new(news[:title]).sentiment_score
      news[:category] = "体育"
      return news
    else
      puts "#{url} invalid!"
      return nil
    end
  end

  def self.news_title(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css("h1#artibodyTitle")
    tmp.text if tmp != nil
  end

  def self.news_pub_date(url)
    @doc ||= Nokogiri::HTML(open(url))

    @doc.css("div.artInfo").children.each do |node|
      node.children.each do |sub_node|
        if sub_node.text =~ /([0-9]{4})年([0-9]{2})月([0-9]{2})日([0-9]{2}:[0-9]{2})/
          return DateTime.parse($1+$2+$3+'T'+$4)
        end
      end
    end
    return nil
  end

  def self.news_image(url)
    @doc ||= Nokogiri::HTML(open(url))
    images = []
    @doc.css("div#artibody div.img_wrapper img").each{|img| images << img["src"]}
  end

  def self.news_text(url)
    @doc ||= Nokogiri::HTML(open(url))
    text = @doc.css("div#artibody p").text
    return text
  end
end

if __FILE__ == $0

  # testing
  require "spidr"
  require 'pry'
  require_relative "../database/db_engine"

  site_url = "http://sports.sina.com.cn"

  Spidr.site(site_url.to_s) do |spider|
    spider.every_page do |page|
      begin
        puts "\nStart process #{page.url}..."        
        parser_result = eval "SinaSportsParser.on \"#{page.url}\" "
        if parser_result != nil
          puts "Saving page #{page.url}..."
          DatabaseEngine.save(parser_result)
          puts "Saving done!"
        end
        puts "Process #{page.url} done!\n"
        
      rescue Exception => e
        puts "Exception: parse #{page.url} failed" 
        puts e.to_s
      end
    end
  end
end
