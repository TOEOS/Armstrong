class API::ArticlesController < API::BaseController
  def index
    @event = Event.find_by(id: params[:event_id])
    if @event
      render json: @event.articles.order(:post_at).includes(:comments)
    else
      render json: {articles:[]}
    end
  end
end
