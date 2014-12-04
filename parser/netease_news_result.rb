require_relative "parser_result"

class NeteaseNewsParserResult < ParserResult
  def validate
    [self[:title], self[:pub_date], self[:text], self[:link]].each do |item|
      if item == nil || item == ""
        return false
      end
    end
    return true
  end
end
