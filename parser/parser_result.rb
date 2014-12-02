class ParserResult < Hash
  attr_accessor :database_to_save
  attr_accessor :table_to_save

  def initialize
    super()
    @database_to_save = "test.db"
    @table_to_save = "test"
  end

  def json
    require "json"
    self.to_json
  end

  def xml
    require "gyoku"
    Gyoku.xml(self)
  end
end
