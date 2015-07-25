@EventApp = React.createClass
  render: ->
    `<div>
      <div className='event-left-wrapper'>
        <EventInfo />
        <EventArticle />
      </div>
      <div className='event-right-wrapper'>
        <Chatroom />
      </div>
    </div>`
