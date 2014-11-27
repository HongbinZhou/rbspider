require "spidr"
require 'nokogiri'
require 'open-uri'
require 'time'
require_relative 'parser/news_parser'

Spidr.site('http://news.163.com/') do |spider|
  spider.every_page do |page|
    puts "[-] #{page.url} :  #{page.content_type} : #{page.title}"
    if page.url.to_s =~ /html/
      puts NewsParser.new(page.url.to_s).news_text
    else
      puts "not a news url"
    end
  end
end

__END__
 for page
title
to_s
code
is_ok?
ok?
timedout?
bad_request?
is_unauthorized?
unauthorized?
is_forbidden?
forbidden?
is_missing?
missing?
had_internal_server_error?
content_type
content_types
content_charset
is_content_type?
plain_text?
txt?
directory?
html?
xml?
xsl?
javascript?
json?
css?
rss?
atom?
ms_word?
pdf?
zip?
cookie
raw_cookie
cookies
cookie_params
nil?

