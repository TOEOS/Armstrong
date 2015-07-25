class EventsController < ApplicationController
  def index
    @hot_events = Event.hot(10)
  end

  def show
  end
end
