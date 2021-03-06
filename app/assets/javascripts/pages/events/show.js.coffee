$(".lazy").lazyload
  effect : "fadeIn"

toDate = (str)->
  date = new Date(str)
  (date.getMonth() + 1) + '/' + date.getDate() + ' ' + date.getHours() + ":" + date.getMinutes()

toYearDate = (str) ->
  date = new Date(str)
  (date.getMonth() + 1) + '/' + date.getDate() + ' ' + date.getHours() + ":" + date.getMinutes()  

class Event
  constructor: ->
    @articles = []
    @loadArticles()

  loadArticles: ->
    # @articles = new vis.DataSet(@mockArticlesData().articles)
    # @currentArticleIndex = @articles.length - 1
    # @timeline = new Timeline(@articles, this)
    # @chatroom = new Chatroom(this)
    # @initWebsocket()
    $.ajax(
      url: '/api/events/1/articles.json'
      method: 'get'
    ).done((data) =>
      _.forEach(data.articles, (article, key) ->
        article.id = key + 1
      )
      @articles = new vis.DataSet(data.articles)
      @currentArticleIndex = @articles.length - 1

      @timeline = new Timeline(@articles, this)
      @chatroom = new Chatroom(this)
      @initWebsocket()
    ).fail( ->
    )

  initWebsocket: ->
    that = this
    event_id = $('#event-data').attr('data-id')
    ws = new WebSocket("ws://localhost:20232?channel=" + event_id)

    ws.onerror = (error) ->

    ws.onclose = ->

    ws.onopen = ->

    ws.onmessage = (data) ->
      data = JSON.parse(data.data)

      if data.data_type == 'message'
        that.chatroom.pushMessage(data.data)
      else if data.data_type == 'article_comment'
        that.chatroom.pushArticleComment(data.data)
      else if data.data_type == 'article'
        that.timeline.pushItem(data.data)

  mockArticlesData: ->
    {
      "articles":[
        {
          "id": 1,
          "event_id": 1,
          "title": "文章標題文章標題文章標題",
          "arthor": "otis",
          "post_at": "2015-07-24T10:27:01.274+08:00",
          "start": "2015-07-24T10:27:01.274+08:00",
          "content": "文章標題文章標題文章標題",
          "article_content": "\u003cp\u003eLorem ipsum m illa dicta sunt, aliquid etiam coronae datum; Ita enim vivunt quidam, ut eorum vita refellatur oratio. Duo Reges: constructio interrete. Ne amores quidem sanctos a sapiente alienos esse arbitrantur. Quando enim Socrates, qui parens philosophiae iure dici potest, quicquam tale fecit? \u003c/p\u003e",
          "comments_count": 12,
          "keywords": "keyword1,keyword2,keyword3",
          "link": "http://localhost:3000/events"
        },
        {
          "id": 2,
          "event_id": 1,
          "title": "文章文章文章",
          "arthor": "otis",
          "post_at": "2015-07-25T10:27:01.274+08:00",
          "start": "2015-07-25T10:27:01.274+08:00",
          "content": "文章文章文章",
          "article_content": "\u003cp\u003eLorem ipsum dolor sit amet,consectetur adipiscing elit. Ego vero volo in virtute vim esse quam maximam; Apud imperitos tum illa dicta sunt, aliquid etiam coronae datum; Ita enim vivunt quidam, ut eorum vita refellatur oratio. Duo Reges: constructio interrete. Ne amores quidem sanctos a sapiente alienos esse arbitrantur. Quando enim Socrates, qui parens philosophiae iure dici potest, quicquam tale fecit? \u003c/p\u003e",
          "comments_count": 12,
          "keywords": "keyword1,keyword2,keyword3",
          "link": "http://localhost:3000/events"
        }
      ]
    }

class Timeline
  constructor: (data_set, event_controller) ->
    @$leftArrow = $('#left-arrow')
    @$rightArrow = $('#right-arrow')

    @event_controller = event_controller
    @items = data_set
    container = document.getElementById('timeline');

    options = {
      width: '100%',
      height: '160px',
      margin: {
        item: 20
      },
      zoomMax: 31536000000,
      zoomMin: 600000,
      template: (item) ->
        "<div class='js-item-info' data-id='#{item.id}'>
          <img style='width: 30px; height: 30px;'
            src='/ptt_icon_50x50.png' alt=''>
          #{item.title}
        </div>"
    }

    # Create a Timeline
    @timeline = new vis.Timeline(container, @items, options)
    @showArticleByIndex(@items.length)
    @initEvent()

  initEvent: ->
    @timeline.on 'select', (props) =>
      $item = $(props.event.target)
      item_id = $item.attr('data-id') || $item.find('.js-item-info').attr('data-id') || $item.closest('.js-item-info').attr('data-id')
      @showArticle(item_id)

    @$leftArrow.on 'click', =>
      @prevArticle()

    @$rightArrow.on 'click', =>
      @nextArticle()

  showArticle: (article_id) ->
    itemIndex = -1
    @items.forEach((data, index) ->
      if Number(data.id) == Number(article_id)
        itemIndex = index
    )
    @showArticleByIndex(itemIndex)

  showArticleByIndex: (index) ->
    if index == -1 || index == undefined
      return
    itemData = @items.get(index)
    @renderArticleContent(itemData)
    @focusTimelinArticle(index)
    @currentArticleIndex = Number(index)
    @refreshArrow()

  renderArticleContent: (article) ->
    $('.Article-Content').html(@articleTemplate(article))

  articleTemplate: (article) ->
    """
      <div class="Article-Info">
        <span class="Article-Source Article-Source--ptt">#{article.source_type || 'PTT'}</span>
        <span class="Article-AuthorAndDate">#{article.arthor + ' | ' + new Date(article.post_at).toLocaleDateString() + ' ' + new Date(article.post_at).toLocaleTimeString()}</span>
      </div>
      <div class="Article-Title">#{article.title}</div>
      <a class="Article-Link" href="#{article.link}">#{article.link}</a>
        <div class="Article-ArticleContent">#{article.article_content}</div>
      <hr>
      #{
        _.reduce(article.comments, (total, comment) =>
          total + @articleCommentTemplate(comment)
        , "")
      }
    """

  articleCommentTemplate: (comment) ->
    """
    <div class="Article-Comment">
      <div class="Article-Comment-Info">
        <span class="Article-Comment-UserName">#{comment.commenter}</span>
        <span class="Article-Comment-Date">#{toDate(comment.created_at)}</span>
      </div>
      <span class="Article-Comment-Content">#{comment.comment.trim()}</span>
    </div>
    """
  pushItem: (data) ->
    @items.update(data.article)

  focusTimelinArticle: (index)->
    @timeline.focus(index)
    @timeline.setSelection(index)

  refreshArrow: ->
    if @currentArticleIndex == undefined
      return

    next = @items.get(@currentArticleIndex + 1)
    prev = @items.get(@currentArticleIndex - 1)

    if next
      @$rightArrow.find('.Arrow-Content').text(next.title)
      @$rightArrow.show()
    else
      @$rightArrow.hide()

    if prev
      @$leftArrow.find('.Arrow-Content').text(prev.title)
      @$leftArrow.show()
    else
      @$leftArrow.hide()

  nextArticle: ->
    @showArticleByIndex(@currentArticleIndex + 1)
  prevArticle: ->
    @showArticleByIndex(@currentArticleIndex - 1)

class Chatroom
  constructor: (event_controller) ->
    @$chatroomList = $('#chatroom-list')
    @$moreMessage = $('#more-message')
    @event_controller = event_controller

    @initEvent()

  initEvent: ->
    that = this
    @$chatroomList.on('click', '.js-article-link', ->
      that.event_controller
        .timeline
        .showArticle($(this).attr('data-id'))
    )

    @$chatroomList.scroll (e) ->
      if ($(this)[0].scrollHeight - $(this).height() - $(this).scrollTop()) > 100
        that.$moreMessage.show()
      else
        that.$moreMessage.hide()

    @$moreMessage.click ->
      that.$chatroomList.animate(
        { scrollTop: that.$chatroomList[0].scrollHeight - that.$chatroomList.height() },
        1000
      )

  pushArticleComment: (data)->
    @$chatroomList.append(@articleCommentTemplate(data.article))

  pushMessage: (data) ->
    @$chatroomList.append(@messageTemplate(data.message))

  messageTemplate: (message) ->
    """
    <div class="Chatroom-Message media js-push-elem">
      <div class="Chatroom-Message-UserPhoto media-left">
        <img src="#{message.user.image}">
      </div>
      <div class="media-body">
        <div class="Chatroom-Message-Username media-heading">
          #{message.user.name}
        </div>
        <div class="Chatroom-Message-Content">
          #{message.content}
        </div>
      </div>
    </div>
    """
  commentTemplate: (comment) ->
    """
    <div class="Chatroom-Article-Comment media">
      <div class="media-left">
        <img src="/message_icon_20x18.png" alt="Message icon">
      </div>
      <div class="media-body">
        #{comment.comment}
      </div>
    </div>
    """

  articleCommentTemplate: (article) ->
    """
      <div class="Chatroom-Article js-push-elem">
        <div class="Chatroom-Article-Title">
          #{article.title}
        </div>
        #{
          _.reduce(article.comments, (total, comment) =>
            total + @commentTemplate(comment)
          , "")
        }
        <a class="Chatroom-Article-Link js-article-link" data-id="#{article.id}">回原文看更多連結</a>
      </div>
    """

window.app = new Event()
