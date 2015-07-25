class Event < ActiveRecord::Base
  has_many :articles
  has_many :messages
  serialize :keywords, Array

  def self.hot(num)
    Event.all
         .map do |e|
           OpenStruct.new(
             e.serializable_hash(
               methods: [:hot, :trend]
             )
           )
         end
         .sort_by do |e|
           e.hot
         end
         .last(10)
         .reverse
  end

  def hot
    event_comments = Comment.where(article_id: articles.ids)

    this_period_event_number = event_comments.where(commented_at: 2.hours.ago..Time.now).length
    prev_period_event_number = event_comments.where(commented_at: 4.hours.ago...2.hours.ago).length

    event_comments.length + (this_period_event_number - prev_period_event_number)
  end

  def trend
    event_comments = Comment.where(article_id: articles.ids)
    
    this_period_event_number = event_comments.where(commented_at: 2.hours.ago..Time.now).length
    prev_period_event_number = event_comments.where(commented_at: 4.hours.ago...2.hours.ago).length

    if prev_period_event_number == 0
      return 100
    else
      ((this_period_event_number - prev_period_event_number) / prev_period_event_number.to_f).round(2)*100
    end
  end
end
