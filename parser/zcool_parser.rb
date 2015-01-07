# coding: utf-8

require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class ZcoolParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    return nil if url !~ /\.s?html$/
    response = open(url)
    @doc = Nokogiri(response)
    news = NeteaseNewsParserResult.new
    news.database_to_save = "zcool.db"
    news.table_to_save    = "new"
    news[:title]          = news_title(url) # must
    news[:pub_date]       = news_pub_date(url) # must
    news[:text]           = news_text(url) # must
    news[:link]           = url            # must
    news[:image]           = news_image(url)

    if news.validate
      puts "#{url} valid!"
      news[:emotion_score] = SentimentText.new(news[:title]).sentiment_score
      news[:category] = "设计"
      return news
    else
      puts "#{url} invalid!"
      return nil
    end
  end

  def self.news_title(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css("h1.workTitle")
    tmp.text.squish if tmp != nil
  end

  def self.news_pub_date(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css("table.workTopBar div.userInforCon span.c999")
    tmp.text if tmp
  end

  def self.news_text(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("div.workInfor").text
  end

  def self.news_image(url)
    @doc ||= Nokogiri::HTML(open(url))
    images = []
    @doc.css("div.workShow div.wsContent img").each do |img|
      images << img["src"]
    end
    images.join(" ")
  end

end

if __FILE__ == $0

  # testing
  require "spidr"
  require 'pry'
  require_relative "../database/db_engine"

  site_url = "http://www.zcool.com.cn/"

  Spidr.site(site_url.to_s) do |spider|
    spider.every_page do |page|
      begin
        puts "\nStart process #{page.url}..."        
        url = page.url
        # url = "http://www.zcool.com.cn/work/ZNjYzNDQxNg==.html"
        parser_result = eval "ZcoolParser.on \"#{url}\" "
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
