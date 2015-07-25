class Event < ActiveRecord::Base
  has_many :articles
  has_many :messages
  serialize :keywords, Array

  def self.hot(num)
    hot_events = []
    num.times do |i|
      hot_events << Event.new(description: "hehehe: #{i}")
    end
    hot_events
  end

  def hot
    50
  end

  def trend
    -69
  end
end
