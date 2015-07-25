class Admin::EventsController < ApplicationController
  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update!(event_params)
    redirect_to edit_admin_event_path(@event)
  end

  protected
  def event_params
    params.require(:event).permit(keywords: [])
  end
end
