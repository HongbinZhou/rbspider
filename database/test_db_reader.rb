require_relative "db_reader"

a = DatabaseReader.new("../net_ease_news.db")
#puts a.get_table_schema("news")
puts a.to_hash_array("news")
