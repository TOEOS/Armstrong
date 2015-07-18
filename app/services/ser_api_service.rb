class SerApiService
  require 'rest-client'

  PATH = {
    base_path: "http://api.ser.ideas.iii.org.tw/api",
    get_token: "/user/get_token",
    top_article_ptt: "/top_article/ptt",
    top_article_facebook: "/top_article/facebook",
    top_article_forum: "/top_article/forum",
    key_word_search_ptt: "/keyword_search/ptt",
    key_word_search_facebook: "/keyword_search/facebook",
    key_word_search_forum: "/keyword_search/forum",
    key_word_search_news: "/keyword_search/news"
  }.freeze

  def initialize
    @uri = PATH[:base_path]
    login
  end

  def top_article_ptt(period: nil, limit: nil, board: nil)
    # required: period <= 30
    path = PATH[:top_article_ptt]
    response = RestClient.post "#{@uri}#{path}",
      period: period,
      limit: limit,
      board: board,
      token: @token

    JSON.parse(response)["result"]
  end

  def top_article_facebook(period: nil, type: nil, page_id_name: nil, limit: nil, board: nil)
    # required: period <= 30
    path = PATH[:top_article_facebook]
    response = RestClient.post "#{@uri}#{path}",
      period: period,
      type: type,
      page_id_name: page_id_name,
      limit: limit,
      board: board,
      token: @token

    JSON.parse(response)["result"]
  end

  def top_article_forum(period: nil, limit: nil, forum: nil)
    # required: period <= 30
    path = PATH[:top_article_forum]
    response = RestClient.post "#{@uri}#{path}",
      period: period,
      limit: limit,
      forum: forum,
      token: @token

    JSON.parse(response)["result"]
  end

  private

  def login
    @id         = Settings.ser_api.id
    @secret_key = Settings.ser_api.secret
    path        = PATH[:get_token]
    response    = RestClient.post "#{@uri}#{path}", id: @id, secret_key: @secret_key

    @token = JSON.parse(response)["result"]["token"]
  end

end
