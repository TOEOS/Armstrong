class SerApiService
  require 'rest-client'

  def initialize
    @uri = Settings.ser_api_path.base_path
    login
  end

  def top_article_ptt(period: period,
                      limit: limit,
                      board: board)
    # required: period <= 30
    path = Settings.ser_api_path.top_article_ptt
    response = RestClient.post "#{@uri}#{path}",
      period: period,
      limit: limit,
      board: board,
      token: @token

    data = JSON.parse(response)["result"]
  end

  def top_article_facebook(period: period,
                           type: type,
                           page_id_name: page_id_name,
                           limit: limit,
                           board: board)
    # required: period <= 30
    path = Settings.ser_api_path.top_article_facebook
    response = RestClient.post "#{@uri}#{path}",
      period: period,
      type: type,
      page_id_name: page_id_name,
      limit: limit,
      board: board,
      token: @token

    data = JSON.parse(response)["result"]
  end

  def top_article_forum(period: period,
                        limit: limit,
                        forum: forum)
    # required: period <= 30
    path = Settings.ser_api_path.top_article_forum
    response = RestClient.post "#{@uri}#{path}",
      period: period,
      limit: limit,
      forum: forum,
      token: @token

    data = JSON.parse(response)["result"]
  end

  private

  def login
    @id         = Settings.ser_api_id
    @secret_key = Settings.ser_api_secret_key
    path       = Settings.ser_api_path.get_token
    response   = RestClient.post "#{@uri}#{path}", id: @id, secret_key: @secret_key

    @token = JSON.parse(response)["result"]["token"]
  end

end