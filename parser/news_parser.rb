class NewsParser
  attr_reader :doc

  require "nokogiri"
  require "open-uri"

  def initialize(news_url)
    @doc = Nokogiri::HTML(open(news_url))
  end

  def is_pure_text_node(node)
    if node.attribute("class") == nil && node.node_name == "p"
      return true
    else
      return false
    end
  end

  def news_title
    @doc.css("#h1title").text
  end

  def news_category
    @doc.css(".ep-crumb")[-1].text
  end

  def news_pub_date
    @doc.css("div.ep-time-soure").each do |node|
      if node.text =~ /来源/
        pub_info = node.text.split("来源:")
        return pub_info[0].gsub(/^\s+/, "")
      end
    end
    return nil
  end

  def news_from_site
    @doc.css("div.ep-time-soure").each do |node|
      if node.text =~ /来源/
        pub_info = node.text.split("来源:")
        return pub_info[1].gsub(" ", "")
      end
    end
    return nil
  end

  def news_image
    images = []
    @doc.css("div#endText").children.each do |node|
      if node.attribute("class").to_s == "f_center"
        images.push(node.children.attribute("src").text)
      end
    end
    images
  end

  def news_video
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

  def news_text
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

__END__

url = ARGV[0]
puts url
news = NewsParser.new(url)
puts news.news_video
puts news.news_image
puts news.news_title
puts news.news_pub_date
puts news.news_from_site
puts news.news_category
puts news.news_text

def get_news_text(url)
  news = {}
  news["text"] = ""
  news["title"] = ""
  news["type"] = ""
  news["pub_date"] = ""
  news["from_site"] = ""
  news["image"] = ""
  news["video"] = ""

  begin
    doc = Nokogiri::HTML(open(url))

    # ++
    # get news title
    # ++
    news["title"] = doc.css("#h1title").text

    # ++
    # get news type
    # ++
    news["type"] = doc.css(".ep-crumb")[-1].text

    # ++
    # get news public date and news source site
    # ++
    doc.css("div.ep-time-soure").each do |node|
      if node.text =~ /来源/
        pub_info = node.text.split("来源:")
        news["pub_date"]= pub_info[0].gsub(/^\s+/, "")
        news["from_site"] = pub_info[1].gsub(" ", "")
      end
    end

    doc.css("div#endText").children.each do |node|
      if node.attribute("class").to_s == "f_center"
        news["image"] = node.children.attribute("src").text
      elsif node.attribute("class").to_s == "video-wrapper"
        node.css(".video-inner").each do |sub_node|
          if sub_node.css(".video script").text =~ /(src=\".*\")/
            news["video"] = $1.split("\"")[1]
          end
        end
      elsif is_pure_text_node(node)
        node.text.squeeze("\n")
        news["text"] += node.text + "\n"
      end
    end

    return news
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
    return nil
  end
end

  def is_pure_text_node(node)
    if node.attribute("class") == nil && node.node_name.to_s == "p"
      node.children.each do |child|
        if child.node_name.to_s == "style"
          return false
        end
      end
      return true
    else
      return false
    end
  end
puts get_news_text(url)


