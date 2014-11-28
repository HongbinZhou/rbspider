class News < ActiveRecord::Base
  validates :title, presence: true, uniqueness: true
  validates :text, presence: true
end
