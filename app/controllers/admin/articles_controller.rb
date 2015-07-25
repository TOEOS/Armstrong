class Admin::ArticlesController < ApplicationController
  def update
    @event = Event.find(params[:event_id])
    @article = Article.find(params[:id])
    @article.update!(article_params)
    redirect_to edit_admin_event_path(@event)
  end

  def destroy
    @event = Event.find(params[:event_id])
    @article = @event.articles.find(params[:id])
    @article.destroy!
    redirect_to edit_admin_event_path(@event)
  end

  protected
  def article_params
    params.require(:article).permit(:title, pic_links: [])
  end
end
