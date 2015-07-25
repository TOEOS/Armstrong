class Article < ActiveRecord::Base
  belongs_to :event
  has_many :comments, dependent: :destroy

  serialize :keywords, Array
  serialize :pic_links, Array

  def post_date
    post_at.strftime("%_m/%d")
  end

  def start
    post_at
  end
end
