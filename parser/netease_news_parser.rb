require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class NeteaseNewsParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    return nil if url !~ /\.html$/
    @doc = Nokogiri::HTML(open(url))
    news = NeteaseNewsParserResult.new
    news.database_to_save = "net_ease_news.db"
    news.table_to_save = "new"
    news[:title] = news_title(url)
    news[:category] = news_category(url)
    news[:pub_date] = news_pub_date(url)
    news[:from_site] = news_from_site(url)
    news[:image] = news_image(url)
    news[:video] = news_video(url)
    news[:text] = news_text(url)
    news[:link] = url
    if news.validate
      news[:pub_date] = DateTime.parse(news[:pub_date])
      news[:emotion_score] = SentimentText.new(news[:title]).sentiment_score
      news[:category] = "新闻"
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
    tmp = @doc.css("#h1title")
    tmp.text if tmp != nil
  end

  def self.news_category(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css(".ep-crumb")[-1]
    tmp.text if tmp != nil
  end

  def self.news_pub_date(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("div.ep-time-soure").each do |node|
      if node.text =~ /来源/
        pub_info = node.text.split("来源:")
        return pub_info[0].gsub(/^\s+/, "")
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
