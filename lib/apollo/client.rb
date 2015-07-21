=begin
推送訊息到 Websocket Server(apollo)，供前端介面顯示

Here is example:
初始化的時候要指定 channel_id，通常是 event id

  client = Apollo::Client.new(4)

推送新的文章(Article)、評論(Reply)、以及聊天室訊息 (Message)，
都是使用 #push() 傳入要推播的 model 物件:

  article = Article.find(99)
  client.push(article)

=end
class Apollo::Client
  SERVER_LOCATION = Settings.apollo.server_location.freeze

  attr_reader :channel_id

  def initialize(channel_id)
    @channel_id = channel_id
  end

  def push(obj)
    Faraday.post do |req|
      req.url "#{SERVER_LOCATION}", channel_id: channel_id
      req.body serielize_obj(obj)
    end
  end

  private

  def serielize_obj(obj)
    case obj
    when Article
      # [TODO]
      # ActiveModel::TimelineAticleSerializer.new(obj).to_json
    when Reply
    when Message
    end
  end
end
