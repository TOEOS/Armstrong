class Event < ActiveRecord::Base
  has_many :articles

  serialize :key_words, Array
end
