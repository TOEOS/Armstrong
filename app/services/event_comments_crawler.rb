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
  extend DebugConfigs

  attr_reader :event_articles

  class << self
    def call
      new.call
    end

    def spawn(number)
      new.split(number)
    end

    def spawn_json(number)
      spawn(number).map {|crawler| crawler.event_articles.to_json }
    end
  end

  def initialize(event_articles = nil)
    @event_articles = event_articles || Article.includes(:comments).where("event_id IS NOT NULL").map(&:attributes)
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
        debug("checking article id: #{a['id']}")

        get_page = false

        while !get_page
          begin
            doc = Nokogiri::HTML(open(a['link'], 'Cookie'=> 'over18=1')).css('#main-container').css('#main-content')
          rescue
            next
          end
          get_page = true
        end

        new_pushes = doc.css('.push')

        new_push_bodies = new_pushes.css('.push-content').map {|new_push| new_push.text[1..-1] }

        last_three_comments = Article.find(a['id']).comments.order(created_at: :desc).limit(3).map(&:comment)

        last_comment_index = last_three_comments.map {|c| new_push_bodies.index(c)}.compact.first || 0

        article_id = a['id']

        new_pushes[last_comment_index..-1].each do |p|
          Comment.create(article_id: article_id, **comment_params(p))
        end
      end

      @called = true
    end
  end

  private

  def comment_params(doc)
    if doc.css('.push-ipdatetime').text.match(/^\d{2}\/\d{2} \d{2}:\d{2}/)
      commented_at = Time.parse(doc.css('.push-ipdatetime').text[0..10])
    else
      commented_at = nil
    end

    {commenter: doc.css('.push-userid').text, comment: doc.css('.push-content').text[1..-1], commented_at: commented_at}
  end
end
