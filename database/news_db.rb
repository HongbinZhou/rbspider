require 'active_record'
require_relative "news"

module NewsDB
  def connect_db(db_type)
    if db_type == "mysql"
      create_db_in_mysql("news")
      ActiveRecord::Base.establish_connection(:adapter => "mysql", :host => "localhost", :username => "root", :password => "hithit", :database => "news")
      if !ActiveRecord::Base.connection.table_exists? "news"
        setup_news_table
      end
    elsif db_type == "sqlite3"
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "data/163.db")
      if !ActiveRecord::Base.connection.table_exists? "news"
        setup_news_table
      end
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
        table.column :image, :text
        table.column :video, :string
        table.column :text, :text
      end
    end
  end

  def save_news(news_info)
    begin
      connect_db("mysql")
      news = News.new(news_info)
      news.save!
      puts "Info: news saved"
    rescue Exception => e
      puts "Info: news not saved -> " + e.message
    end
  end

  private
  def create_db_in_mysql(database_name)
    if !db_exist?(database_name)
      cmd = "mysql -uroot -phithit  -e \"create database #{database_name};\""
      if system(cmd)
        puts "Info: database #{database_name} created in mysql"
      else
        puts "Fatal: database #{database_name} created failed"
      end
    end
  end

  def db_exist?(database_name)
    cmd = "mysql -uroot -phithit -e \"use #{database_name}\""
    if system(cmd)
      return true
    else
      return false
    end
  end
end
