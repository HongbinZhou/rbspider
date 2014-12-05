require "sqlite3"

db_file = ARGV[0]
db = SQLite3::Database.new db_file
result = []
db.execute("select * from news") do |row|
  news = Hash.new
  news[:title] = row[1]
  news[:category] = row[2]
  news[:pub_date] = row[3]
  news[:from_site_] = row[4]
  news[:image] = row[5]
  news[:video] = row[6]
  news[:text] = row[7]
  news[:link] = row[8]
  news[:emotion_score] = row[9]
  result.push news
end

puts result[0]

