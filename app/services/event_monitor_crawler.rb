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
  extend DebugConfigs

  attr_reader :unclassed_articles

  class << self
    def call
      new.call
    end

    def spawn(number)
      new.split(number)
    end

    def spawn_json(number)
      spawn(number).map {|crawler| crawler.unclassed_articles.to_json }
    end
  end

  def initialize(unclassed_articles = nil)
    @unclassed_articles = unclassed_articles || Article.where("event_id IS NULL AND post_at > ?", 1.days.ago).map(&:attributes)
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
        debug("parsing article, id: #{a['id']}")

        get_page = false

        get_404 = false

        while !get_page
          begin
            doc = Nokogiri::HTML(open(a['link'], 'Cookie'=> 'over18=1')).css('#main-container').css('#main-content')
          rescue => e
            e.message == "404 Not Found" ? (get_404 = true; break;) : next
          end
          get_page = true
        end

        next if get_404

        new_push_number = doc.css('.push').length

        if new_push_number > 100 || (new_push_number > 30 && (new_push_number - a['comments_count'])/(Time.now - a['post_at'].to_time) > (30/120.0))
          if belonged_event = belongs_to_existing_event(a)
            Article.find(a['id']).update!(event_id: belonged_event.id)
          else
            event = Event.create!(keywords: a['keywords'], description: a['title'].split(']')[1..-1].join.lstrip)
            @events << event
            Article.find(a['id']).update!(event_id: event.id)
          end
        else
          debug("article not qualified, id: #{a['id']}")
        end
      end

      @called = true
    end
  end

  private

  def belongs_to_existing_event(article)
    EventMatchService.best_match_event(@events, article['keywords'])
  end
end
