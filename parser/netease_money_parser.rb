# coding: utf-8

require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class NeteaseMoneyParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    return nil if url !~ /\.s?html$/
    response = open(url)
    @doc = Nokogiri(response)
    news = NeteaseNewsParserResult.new
    news.database_to_save = "neteast_money_news.db"
    news.table_to_save    = "new"
    news[:title]          = news_title(url) # must
    news[:pub_date]       = news_pub_date(url) # must
    news[:text]           = news_text(url) # must
    news[:link]           = url            # must
    if news.validate
      puts "#{url} valid!"
      news[:emotion_score] = SentimentText.new(news[:title]).sentiment_score
      news[:category] = "财经"
      return news
    else
      puts "#{url} invalid!"
      return nil
    end
  end

  def self.news_title(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css("h1#h1title")
    tmp.text if tmp != nil
  end

  def self.news_pub_date(url)
    @doc ||= Nokogiri::HTML(open(url))

    if @doc.css("div.ep-time-soure").text =~ /([0-9]{4}\-[0-9]{2}\-[0-9]{2})/
      return DateTime.parse($1.gsub("-", ""))
    end

    return nil
  end

  def self.news_text(url)
    @doc ||= Nokogiri::HTML(open(url))
    text = @doc.css("div#endText p").text
    return text
  end
end

if __FILE__ == $0

  # testing
  require "spidr"
  require 'pry'
  require_relative "../database/db_engine"

  site_url = "http://money.163.com/"

  Spidr.site(site_url.to_s) do |spider|
    spider.every_page do |page|
      begin
        puts "\nStart process #{page.url}..."        
        # url = page.url
        url = "http://money.163.com/15/0106/20/AFA69Q8D00253B0H.html"
        parser_result = eval "NeteaseMoneyParser.on \"#{url}\" "
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
