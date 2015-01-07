require "optparse"
require "spidr"
require 'nokogiri'
require 'open-uri'
require 'time'
require_relative 'parser/netease_news_parser'
require_relative "database/db_engine"
require_relative "parser/36kr_news_pareser"
require_relative "parser/techcrunch_news_parser"
require_relative "parser/sina_sports_parser"
require_relative "parser/netease_money_parser"
require_relative "parser/zcool_parser"
require_relative "parser/trends_parser"

class RbSpider
  def run(options)
    site_url = options["site"]
    spider_mode = options["mode"] || "single"
    spider_parser = options["parser"] || "default"

    if site_url && spider_mode && spider_parser
      if spider_mode == "single"
        Spidr.site(site_url.to_s) do |spider|
          spider.every_page do |page|
            begin
              parser_result = eval "
               #{spider_parser}.on \"#{page.url}\"
              "
              if parser_result != nil
                DatabaseEngine.save(parser_result)
              end
            rescue Exception => e
              puts "Exception: parse #{page.url} failed" 
              puts e.to_s
            end
          end
        end
      elsif spider_mode == "multiple"
        Spidr.start_at(site_url) do |spider|
          spider.every_page do |page|
            begin
              parser_result = eval "
                #{spider_parser}.on \"#{page.url}\"
              "
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
    end
  end
end

def read_config(file)
  require "json"
  JSON.parse(IO.read(file))
end

# ++
# main
# ++

options = {}
OptionParser.new do |opts|
  opts.banner = "rbspider, it's simple and nice spider"

  opts.on("-c ", "--configure", "Run with a configure") do |val|
    options[:configure] = val
  end

  opts.on("-s ", "--site", "Spider a site") do |val|
    options[:site] = val
  end

  opts.on("-m ", "--mode", "Spider mode\n\t\t\t\t\tsingle: single site\n\t\t\t\t\tmultiple: multiple site") do |val|
    options[:mode] = val
  end
end.parse!

if options[:configure]
  options = read_config(options[:configure])
  threads = []
  options.each do |opts|
    threads << Thread.new {
      spider = RbSpider.new
      spider.run(opts)
    }
  end

  threads.each { |t| t.join }
else
  spider = RbSpider.new
  spider.run(options)
end
