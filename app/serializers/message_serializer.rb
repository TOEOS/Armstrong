class MessageSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :title, :arthor, :post_at, :start, :content, :article_content, :comments_count, :keywords, :link

  def start
    object.post_at
  end
  def content
    object.title
  end
  def article_content
    object.content
  end
end
