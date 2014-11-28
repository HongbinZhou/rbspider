require 'active_record'
require_relative "news"

module NewsDB
  def connect_db
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "data/163.db")
    if !ActiveRecord::Base.connection.table_exists? "news"
      setup_news_table
    end
  end

  # ++
  # creat table in database
  # ++
  def setup_news_table
    ActiveRecord::Schema.define do
  #    drop_table :news if table_exists? :news
      create_table :news do |table|
        table.column :title, :string
        table.column :category, :string
        table.column :pub_date, :string
        table.column :from_site, :string
        table.column :image, :string
        table.column :video, :string
        table.column :text, :string
      end
    end
  end

  def save_news(news_info)
    begin
      connect_db
      news = News.new(news_info)
      news.save!
      puts "Info: news saved"
    rescue Exception => e
      puts "Info: news not saved -> " + e.message
    end
  end
end
