class Article < ActiveRecord::Base
  belongs_to :event
  has_many :comments, dependent: :destroy

  serialize :keywords, Array

  def post_date
    post_at.strftime("%_m/%d")
  end
end
