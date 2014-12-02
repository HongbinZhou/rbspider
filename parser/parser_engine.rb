class ParserEngine
  private
  def self.on(url)
    raise "Exception: this method should be override by subclass and return ParserResult instance"
  end
end
