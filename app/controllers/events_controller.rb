class EventsController < ApplicationController
  def index
    @hot_events = Event.hot(10)
  end

  def show
      @event = Event.find(params[:id])
  end

  def create_message
    @event = Event.find(params[:event_id])
    @message = @event.messages.build(content: params[:event][:messages][:content])
    @message.user = current_user || User.new(id: 1)
    @message.save!

    client = Apollo::Client.new(@event.id)
    client.push(@message, 'message')
    render json: {result: 'ok'}
  end
end
