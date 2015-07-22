# How to Use
# 
# 1. update all event comments
# 
#      EventCommentsCrawler.call
# 
#      or
# 
#      EventCommentsCrawler.new.call
# 
# 2. update all event comments in N batch
#   
#      event_comments_crawlers = EventCommentsCrawler.spawn(4)
#      #=> [#<EventCommentsCrawler>, #<EventCommentsCrawler>, #<EventCommentsCrawler>, #<EventCommentsCrawler>]
# 
#      event_comments_crawlers.each(&:call)
#      #=> crawlers will start update event comments each by each
#

class EventCommentsCrawler
  class << self
    def call
      new.call
    end

    def spawn(number)
      new.split(number)
    end
  end

  def initialize(event_articles = nil)
    @event_articles = event_articles || Article.includes(:comments).where("event_id IS NOT NULL")
  end

  def split(number)
    if !@called
      @event_articles.
        each_slice(@event_articles.length / number + 1).
        map {|group_of_articles| self.class.new(group_of_articles) }
    end
  end

  def call
    if !@called
      @event_articles.each do |a|
        get_page = false

        while !get_page
          begin
            doc = Nokogiri::HTML(open(a.link, 'Cookie'=> 'over18=1')).css('#main-container').css('#main-content')
          rescue
            next
          end
          get_page = true
        end

        new_pushes = doc.css('.push')

        new_pushe_bodies = new_pushes.css('.push-content').map(&:text)

        last_three_comments = a.comments.order(created_at: :desc).limit(3).map(&:comment)

        last_comment_index = last_three_comments.map {|c| new_pushe_bodies.index(c)}.compact.first

        article_id = a.id

        new_pushes[last_comment_index..-1].each do |p|
          Comment.create(article_id: article_id, **comment_params(p))
        end
      end

      @called = true
    end
  end

  private

  def comment_params(doc)
    {commenter: doc.css('.push-userid').text, comment: doc.css('.push-content').text[1..-1]}
  end
end
