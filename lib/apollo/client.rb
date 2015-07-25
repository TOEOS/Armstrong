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
  SERVER_LOCATION = Settings.apollo.api_server.freeze
  TYPE = {
    article: 'article',
    article_comment: 'article_comment',
    message: 'message'
  }.freeze

  attr_reader :channel_id

  def initialize(channel_id)
    @channel_id = channel_id
  end

  def push!(obj, type)
    resp = Faraday.post do |req|
      req.url("#{SERVER_LOCATION}armstrong_push", channel: channel_id)
      req.body = serialize_obj(obj, type)
    end

    if (resp.status/100) == 4
      raise "Error, #{resp.status}"
    end
  end

  def push(*args)
    push!(*args)
    true
  rescue
    false
  end

  private

  def serialize_obj(obj, type)
    type = type.downcase
    raise "arguments must be one of #{TYPE.values}" unless TYPE.values.include?(type)

    case type
    when TYPE[:article]
      Jbuilder.encode do |json|
        json.data_type type
        json.data do
          json.article do
            json.id              obj.id
            json.event_id        obj.event_id
            json.title           obj.title
            json.arthor          obj.arthor
            json.post_at         obj.post_at
            json.start           obj.start
            json.content         obj.content
            json.article_content obj.article_content
            json.comments_count  obj.comments_count
            json.keywords        obj.keywords
            json.link            obj.link
            json.comments        obj.comments
          end
        end
      end
    when TYPE[:article_comment]
      Jbuilder.encode do |json|
        json.data_type type
        json.data do
          json.article do
            json.id              obj.id
            json.event_id        obj.event_id
            json.title           obj.title
            json.comments        obj.comments
          end
        end
      end
    when TYPE[:message]
      Jbuilder.encode do |json|
        json.data_type type
        json.data do
          json.message do
            json.id              obj.id
            # json.event_id        obj.event_id
            json.content         obj.content
            json.user            obj.user
          end
        end
      end
    end
  end
end
