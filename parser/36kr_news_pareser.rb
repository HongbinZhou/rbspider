require_relative "parser_engine"
require_relative "netease_news_result"
require_relative "sentiment_analysis"

class Kr36NewsParser < ParserEngine
  require "nokogiri"
  require "open-uri"

  private
  def self.on(url)
    return nil if url !~ /\.html$/
    @doc = Nokogiri::HTML(open(url))
    news = NeteaseNewsParserResult.new
    news.database_to_save = "36kr_news.db"
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
    tmp = @doc.css("h1.single-post__title")[-1]
    tmp.text if tmp != nil
  end

  def self.news_category(url)
    "互联网"
  end

  def self.news_pub_date(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("div.single-post__postmeta").children.each do |node|
      if node.text =~ /([0-9]{2}\/[0-9]{2})\s+([0-9]{2}:[0-9]{2})/
        pub_date = ($1 + $2).gsub("/", "").gsub(":", "")
        return DateTime.parse(Time.new.year.to_s + pub_date)
      end
    end
    return nil
  end

  def self.news_from_site(url)
    return "36Kr"
  end

  def self.news_image(url)
    @doc ||= Nokogiri::HTML(open(url))
    images = []
    @doc.css("section.article").each do |node|
      node.children.each do |sub_node|
        if sub_node.node_name == "p" && sub_node.children != nil
          sub_node.children.each do |sub_sub_node|
            if sub_sub_node.node_name == "img"
              images.push sub_sub_node["src"]
            end
          end
        end
      end
    end
    images.join(" ")
  end

  def self.news_video(url)
    @doc ||= Nokogiri::HTML(open(url))
    @doc.css("section.article").each do |node|
      node.children.each do |sub_node|
        if sub_node.node_name == "iframe"
          return sub_node["src"]
        end
      end
    end
    return nil
  end

  def self.news_text(url)
    @doc ||= Nokogiri::HTML(open(url))
    text = ""
    @doc.css("section.article").each do |node|
      node.children.each do |sub_node|
        if sub_node.node_name == "p"
          text += node.text + "\n"
        end
      end
    end
    return text
  end
end
