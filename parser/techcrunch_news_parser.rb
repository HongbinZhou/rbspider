require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class TechcrunchNewsParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    @doc = Nokogiri::HTML(open(url))
    news = NeteaseNewsParserResult.new
    news.database_to_save = "techcrunch_news.db"
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
      news[:emotion_score] = SentimentText.new(news[:title]).sentiment_score
      return news
    else
      return nil
    end
  end

  def self.news_title(url)
    @doc ||= Nokogiri::HTML(open(url))
    tmp = @doc.css("h1.alpha.tweet-title")[-1]
    tmp.text if tmp != nil
  end

  def self.news_category(url)
    "互联网"
  end

  def self.news_pub_date(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("div.byline").children.each do |node|
      node.children.each do |sub_node|
        if sub_node.text =~ /([0-9]{4}\.[0-9]{2}\.[0-9]{2})/
          return DateTime.parse($1.gsub(".", ""))
        end
      end
    end
    return nil
  end

  def self.news_from_site(url)
    return "Techcrunch中国"
  end

  def self.news_image(url)
    @doc ||= Nokogiri::HTML(open(url))
    images = []
    @doc.css("article.article.lc").each do |node|
      node.children.each do |sub_node|
        next if sub_node.node_name == "header"
        images.push sub_node["src"] if sub_node.node_name == "img"
      end
    end
    images.join(" ")
  end

  def self.news_video(url)
    return nil
  end

  def self.news_text(url)
    text = ""
    @doc.css("div.article-entry").each do |node|
      node.children.each do |sub_node|
        if sub_node.node_name == "p"
          text += sub_node.text + "\n"
        end
      end
    end
    return text
  end
end
