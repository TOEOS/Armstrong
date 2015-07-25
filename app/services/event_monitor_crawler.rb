# How to Use
# 
# 1. monitor all articles
# 
#      EventMonitorCrawler.call
# 
#      or
# 
#      EventMonitorCrawler.new.call
# 
# 2. monitor all articles in N batch
#   
#      event_monitor_crawlers = EventMonitorCrawler.spawn(4)
#      #=> [#<EventMonitorCrawler>, #<EventMonitorCrawler>, #<EventMonitorCrawler>, #<EventMonitorCrawler>]
# 
#      event_monitor_crawlers.each(&:call)
#      #=> crawlers will start monitoring each by each
#

class EventMonitorCrawler
  class << self
    def call
      new.call
    end

    def spawn(number)
      new.split(number)
    end
  end

  def initialize(unclassed_articles = nil)
    @unclassed_articles = unclassed_articles || Article.where("event_id IS NULL AND post_at > ?", 1.days.ago)
    @events = Event.all
  end

  def split(number)
    if !@called
      @unclassed_articles.
        each_slice(@unclassed_articles.length / number + 1).
        map {|group_of_articles| self.class.new(group_of_articles) }
    end
  end

  def call
    if !@called
      @unclassed_articles.each do |a|
        get_page = false

        while !get_page
          begin
            doc = Nokogiri::HTML(open(a.link, 'Cookie'=> 'over18=1')).css('#main-container').css('#main-content')
          rescue
            next
          end
          get_page = true
        end

        new_push_number = doc.css('.push').length

        if new_push_number > 100 || (new_push_number > 30 && (new_push_number - a.comments_count)/(Time.now - a.post_at) > (30/120.0))
          if belonged_event = belongs_to_existing_event(a)
            belonged_event.articles << a
          else
            Event.new(keywords: a.keywords)
          end
        end
      end

      @called = true
    end
  end

  private

  def belongs_to_existing_event(article)
    EventMatchService.best_match_event(@evnets, keywords)
  end
end
