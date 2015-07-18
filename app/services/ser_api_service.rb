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
    key_word_search_news: "/keyword_search/news",
    key_word_search_id_on_content_party: "/search_article_id",
    search_article_by_id_on_content_party: "/get_article"
  }.freeze

  CONTENT_PARTY_TOKEN = {
    base_path: "http://contentparty.org:80/api",
    token: "c4b5f1b2759b7d3a7e76a20d3ada74c9"
  }.freeze

  def initialize
    @ser_uri = PATH[:base_path]
    @conten_party_uri = CONTENT_PARTY_TOKEN[:base_path]
    login
  end

  def top_article_ptt(period: period, limit: nil, board: nil)
    # required: period <= 30
    path = PATH[:top_article_ptt]
    response = RestClient.post "#{@ser_uri}#{path}",
      period: period,
      limit: limit,
      board: board,
      token: @token

    JSON.parse(response)["result"]
  end

  def keyword_search_ptt(keyword: keyword,
                         type: nil,
                         limit: nil,
                         page: nil,
                         strat_date: nil,
                         end_date: nil,
                         push: nil,
                         sort: nil)
    path = PATH[:key_word_search_ptt]
    response = RestClient.post "#{@ser_uri}#{path}",
      keyword: keyword,
      type: type,
      limit: limit,
      page: page,
      strat_date: strat_date,
      end_date: end_date,
      push: push,
      sort: sort,
      token: @token

    JSON.parse(response)["result"]
  end

  def top_article_facebook(period: period,
                           type: nil,
                           page_id_name: nil,
                           limit: nil,
                           board: nil)
    # required: period <= 30
    path = PATH[:top_article_facebook]
    response = RestClient.post "#{@ser_uri}#{path}",
      period: period,
      type: type,
      page_id_name: page_id_name,
      limit: limit,
      board: board,
      token: @token

    JSON.parse(response)["result"]
  end

  def keyword_search_facebook(keyword: keyword,
                              limit: nil,
                              page: nil,
                              strat_date: nil,
                              end_date: nil,
                              comments: nil,
                              likes: nil,
                              shares: nil,
                              sort: nil)
    path = PATH[:key_word_search_facebook]
    response = RestClient.post "#{@ser_uri}#{path}",
      keyword: keyword,
      limit: limit,
      page: page,
      strat_date: strat_date,
      end_date: end_date,
      comments: comments,
      likes: likes,
      shares: shares,
      sort: sort,
      token: @token

    JSON.parse(response)["result"]
  end

  def top_article_forum(period: period, limit: nil, forum: nil)
    # required: period <= 30
    path = PATH[:top_article_forum]
    response = RestClient.post "#{@ser_uri}#{path}",
      period: period,
      limit: limit,
      forum: forum,
      token: @token

    JSON.parse(response)["result"]
  end

  def keyword_search_forum(keyword: keyword,
                           type: nil,
                           limit: nil,
                           page: nil,
                           strat_date: nil,
                           end_date: nil,
                           reply: nil,
                           sort: nil)
    path = PATH[:key_word_search_forum]
    response = RestClient.post "#{@ser_uri}#{path}",
      keyword: keyword,
      type: type,
      limit: limit,
      page: page,
      strat_date: strat_date,
      end_date: end_date,
      reply: reply,
      sort: sort,
      token: @token

    JSON.parse(response)["result"]
  end

  def keyword_search_news(keyword: keyword,
                          type: nil,
                          limit: nil,
                          page: nil,
                          strat_date: nil,
                          end_date: nil,
                          reply: nil,
                          sort: nil)
    path = PATH[:key_word_search_news]
    response = RestClient.post "#{@ser_uri}#{path}",
      keyword: keyword,
      type: type,
      limit: limit,
      page: page,
      strat_date: strat_date,
      end_date: end_date,
      reply: reply,
      sort: sort,
      token: @token

    JSON.parse(response)["result"]
  end

  def key_word_search_id_on_content_party(keyword: keyword,
                                          type: nil,
                                          site: nil,
                                          author: nil,
                                          limit: nil,
                                          page: nil,
                                          sort: nil)
    path = PATH[:key_word_search_id_on_content_party]
    response = RestClient.post "#{@conten_party_uri}#{path}",
      keyword: keyword,
      type: type,
      site: site,
      author: author,
      limit: limit,
      page: page,
      sort: sort,
      token: CONTENT_PARTY_TOKEN[:token]

    JSON.parse(response)["result"]
  end

  def search_article_by_id_on_content_party(data_id: data_id)
    path = PATH[:search_article_by_id_on_content_party]
    response = RestClient.post "#{@conten_party_uri}#{path}",
      data_id: data_id,
      token: CONTENT_PARTY_TOKEN[:token]

    JSON.parse(response)["result"]
  end

  private

  def login
    @id         = Settings.ser_api.id
    @secret_key = Settings.ser_api.secret
    path        = PATH[:get_token]
    response    = RestClient.post "#{@ser_uri}#{path}", id: @id, secret_key: @secret_key

    @token = JSON.parse(response)["result"]["token"]
  end

end
