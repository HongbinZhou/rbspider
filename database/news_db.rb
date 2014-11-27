require 'active_record'

# ++
# we gonna use ActiveRecord outside of rails because of
# following reasons:
#   1. get more known of rails
#     rails tools takes care of too much stuff for me, which make
#     me no aware of a lot thing happen behind it.
#   2. rails is too big and to complicated
#     rails is very excellent MVC implementation, is a very great
#     material to learn MVC from, but the best way to do it is create
#     a own MVC framworkw with rails's component.
#     this is not easy of caus.  but we can start with build rails
#     from pieces of source codes, this will help us get more familiar
#     with rails.
# ++

# ++
# let's start it.
# ++

module NewsDB
  private
  # ++
  # connect to database.
  # I am using sqlite3 here, actually you can use different database, MySQL, etc.
  # ++
  def self.connect_db
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "./163.db")
  end

  # ++
  # creat table in database
  # ++
  def self.setup_news_table
    ActiveRecord::Schema.define do
      drop_table :news if table_exists? :news
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
end
