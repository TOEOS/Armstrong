@Timeline = React.createClass
  componentDidMount: ->
    container = document.getElementById('timeline');

    # Create a DataSet (allows two way data-binding)
    items = new vis.DataSet([
      {id: 1, content: 'item 1', start: '2013-04-20', className: 'timeline-item'},
      {id: 2, content: 'item 2', start: '2013-04-14'},
      {id: 3, content: 'item 3', start: '2013-04-18'},
      {id: 4, content: 'item 4', start: '2013-04-16'},
      {id: 5, content: 'item 5', start: '2013-04-25'},
      {id: 6, content: 'item 6', start: '2013-04-27'}
    ])

    # Configuration for the Timeline
    options = {
      width: '100%',
      height: '200px',
      margin: {
        item: 20
      },
      zoomMAx: 31536000000
    }

    # Create a Timeline
    timeline = new vis.Timeline(container, items, options)

  render: ->
    `<div key='event-timeline' id='timeline'></div>`
