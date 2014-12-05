class DatabaseReader
  require "sqlite3"
  require "date"

  def initialize(db_file)
    @db = SQLite3::Database.new db_file
  end

  def to_hash_array(table_name)
    table_schema = get_table_schema(table_name)
    result = []
    @db.execute("select * from #{table_name}") do |row|
      news = {}
      i = 0
      table_schema.each_pair do |key, val|
        if val =~ /datetime/ || val =~ /DateTime/
          news[key.to_sym] = DateTime.parse(row[i])
        else
          news[key.to_sym] = row[i]
        end
        i += 1
      end
      result.push news
    end
    return result
  end

  def get_table_schema(table_name)
    schema = {}
    @db.execute("PRAGMA table_info(#{table_name})") do |row|
      schema[row[1].to_sym] = row[2]
    end
    return schema
  end
end

