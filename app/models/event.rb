class Event < ActiveRecord::Base
  has_many :articles

  serialize :keywords, Array
end
