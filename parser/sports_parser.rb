# coding: utf-8
require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class SportsParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    return nil if url !~ /\.html$/
    url="http://sports.sina.com.cn/nba/2015-01-05/13037470558.shtml"
    @doc = Nokogiri::HTML(open(url))
    news = NeteaseNewsParserResult.new
    news.database_to_save = "sports_news.db"
    news.table_to_save = "new"
    news[:title] = news_title(url) # must
    news[:category] = news_category(url)
    news[:pub_date] = news_pub_date(url) # must
    binding.pry
    news[:from_site] = news_from_site(url)
    news[:image] = news_image(url)
    news[:video] = news_video(url)
          binding.pry
    news[:text] = news_text(url) # must
    news[:link] = url            # must


    if news.validate
      news[:pub_date] = DateTime.parse(news[:pub_date])
      news[:emotion_score] = SentimentText.new(news[:title]).sentiment_score
      news[:category] = "体育"
      return news
    else
      return nil
    end
  end

  def self.is_pure_text_node(node)
    if node.attribute("class") == nil && node.node_name == "p"
      return true
    else
      return false
    end
  end

  def self.news_title(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css("title")
    tmp.text if tmp != nil
  end

  def self.news_category(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css(".ep-crumb")[-1]
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

  def self.news_from_site(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("div.ep-time-soure").each do |node|
      if node.text =~ /来源/
        pub_info = node.text.split("来源:")
        return pub_info[1].gsub(" ", "")
      end
    end
    return nil
  end

  def self.news_image(url)
    @doc ||= Nokogiri::HTML(open(url))
    images = []
    @doc.css("div#endText").children.each do |node|
      if node.attribute("class") != nil
        if node.attribute("class").text == "f_center" || node.attribute("class").text == "center"
          if node.node_name.to_s == "p"
            node.children.each do |sub_node|
              if sub_node.node_name == "img"
                if sub_node.attribute("src")
                  images.push(sub_node.attribute("src").text)
                end
              end
            end
          end
        end
      end
    end
    images.join(" ")
  end

  def self.news_video(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("div#endText").children.each do |node|
      if node.attribute("class").to_s == "video-wrapper"
        node.css(".video-inner").each do |sub_node|
          if sub_node.css(".video script").text =~ /(src=\".*\")/
            return $1.split("\"")[1]
          end
        end
      end
    end
  end

  def self.news_text(url)
    @doc ||= Nokogiri::HTML(open(url))
    text = ""
    @doc.css("div#endText p").each do |node|
      if is_pure_text_node(node)
        #node.text.squeeze("\n")
        text += node.text + "\n"
      end
    end
    return text
  end
end

if __FILE__ == $0

  # testing
  require "spidr"
  require 'pry'
  site_url = "http://sports.sina.com.cn"

  Spidr.site(site_url.to_s) do |spider|
    spider.every_page do |page|
      begin
        parser_result = eval "SportsParser.on \"#{page.url}\" "
        if parser_result != nil
          DatabaseEngine.save(parser_result)
        end
      rescue Exception => e
        puts "Exception: parse #{page.url} failed" 
        puts e.to_s
      end
    end
  end
end
