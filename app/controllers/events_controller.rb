class EventsController < ApplicationController
  def index
    @hot_events = Event.hot(10)
  end

  def show
    begin
      @event = Event.find(params[:id])
    rescue
      @event = Event.new(description: "o~hohohohohohohoho")
    end
  end
end
