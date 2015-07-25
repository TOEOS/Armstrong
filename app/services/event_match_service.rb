class EventMatchService
  extend DebugConfigs

  class << self
    def best_match_event(events, article_keywords, number = 1)
      matches = events.map {|event| [event, EventMatchService.new(event).match_level(article_keywords)] }.
                  select {|event, match_level| match_level > 0.5 }.
                  sort_by {|event, match_level| 1 - match_level}.first(number).
                  map {|event, match_level| event }

      debug("\rclassify to Event.id = #{matches.first.id}                    ") if !matches.empty?

      number == 1 ? matches.first : matches
    end
  end

  def initialize(event)
    @event = event
  end

  def is_match(article_keywords)
    (@event.keywords - article_keywords).length < @event.keywords.length / 2
  end

  def match_level(article_keywords)
    (@event.keywords & article_keywords).length / @event.keywords.length.to_f
  end
end
