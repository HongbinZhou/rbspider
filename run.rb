#!/usr/bin/ruby

require "optparse"
require "spidr"
require 'nokogiri'
require 'open-uri'
require 'time'
require_relative 'parser/netease_news_parser'
require_relative "database/db_engine"

class RbSpider
  def run(options)
    site_url = options["site"]
    spider_mode = options["mode"] || "single"
    spider_parser = options["parser"] || "default"

    if site_url && spider_mode && spider_parser
      if spider_mode == "single"
        puts site_url
        Spidr.site(site_url.to_s) do |spider|
          spider.every_page do |page|
            parser_result = eval "
             #{spider_parser}.on \"#{page.url}\"
            "
            DatabaseEngine.save(parser_result)
          end
        end
      elsif spider_mode == "multiple"
        Spidr.start_at(site_url) do |spider|
          spider.every_page do |page|
            parser_result = eval "
              #{spider_parser}.on \"#{page.url}\"
            "
            DatabaseEngine.save(parser_result)
          end
        end
      end
    end
  end
end

def read_config(file)
  require "json"
  puts file
  JSON.parse(IO.read(file))
end

# ++
# main
# ++
$VERBOSE = nil

options = {}
OptionParser.new do |opts|
  opts.banner = "rbspider, it's simple and nice spider"

  opts.on("-c ", "--configure", "Run with a configure") do |val|
    options[:configure] = val
  end

  opts.on("-s ", "--site", "Spider a site") do |val|
    options[:site] = val
  end

  opts.on("-m ", "--mode", "Spider mode\n\tsingle: single site\n\tmultiple: multiple site") do |val|
    options[:mode] = val
  end
end.parse!

if options[:configure]
  options = read_config(options[:configure])
  options.each do |opts|
    spider = RbSpider.new
    spider.run(opts)
  end
else
  spider = RbSpider.new
  spider.run(options)
end
