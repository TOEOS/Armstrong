class EventMatchService
  def initialize(event)
    @event = event
  end

  def is_match(article_keywords)
    (@event.keywords - article_keywords).length < @event.keywords.length / 2
  end
end
