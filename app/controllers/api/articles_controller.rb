class API::ArticlesController < API::BaseController
  def index
    @articles = Article.all
    respond_to do |format|
      format.json
    end
  end
end
