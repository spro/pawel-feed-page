console.log 'Welcome to pawel feed page.'

MessagesStore =
    messages: []
    since: new Date().getTime()

MessagesDispatcher = _.extend Backbone.Events,

    loadMessages: ->
        $.getJSON '/messages.json?since=' + MessagesStore.since, (response) ->
            messages = response.data
            MessagesStore.messages = MessagesStore.messages.concat messages
            MessagesStore.since = response.meta.since
            MessagesDispatcher.trigger 'update'

    addMessage: (message) ->
        MessagesStore.messages = [message].concat MessagesStore.messages
        MessagesDispatcher.trigger 'update'

    addComment: (message, comment) ->
        message.comments.unshift comment
        MessagesDispatcher.trigger 'update'

window.Avatar = React.createClass
    render: ->
        `<img className="avatar" src={this.props.src} />`

window.Loader = React.createClass
    render: ->
        return `(
            <div className="loader">
                <i className="fa fa-spin fa-spinner" />
            </div>
        )`

window.Comments = React.createClass

    getInitialState: ->
        loading: true

    render: ->
        comments = @props.message.comments.map (c) ->
            `<Comment comment={c} key={c.time} />`

        return `(
            <div className="comments">
                <NewComment message={this.props.message} />
                {comments}
            </div>
        )`

window.NewComment = React.createClass

    getInitialState: ->
        body: ''

    makeComment: ->
        user:
            name: 'fred'
            avatar: 'http://avc.com/wp-content/uploads/2014/01/freds-avatar.jpg'
        body: @state.body
        time: new Date().getTime()

    addComment: (e) ->
        e.preventDefault()
        MessagesDispatcher.addComment @props.message, @makeComment()
        @setState body: ''

    updateBody: (e) ->
        e.preventDefault()
        @setState body: e.target.value

    render: ->
        `(
            <div className="new-comment">
                <form onSubmit={this.addComment}>
                    <input className="form-control" type="text"
                        placeholder="Post a comment..."
                        value={this.state.body} onChange={this.updateBody}
                    />
                </form>
            </div>
        )`

window.Comment = React.createClass
    
    render: ->
        comment = @props.comment
        comment_time = "posted this " + moment(comment.time).fromNow()

        return `(
            <div className="comment">
                <img className="avatar" src={comment.user.avatar} />
                <div className="details">
                    <span className="name">{comment.user.name}</span>
                    <span classbody="body">{comment.body}</span>
                    <span className="time">{comment_time}</span>
                </div>
            </div>
        )`

window.Message = React.createClass

    getInitialState: ->
        open: false

    updateMessage: (message) ->
        @setProps message: message

    toggleComments: ->
        @setState open: !@state.open

    render: ->
        message = @props.message
        #console.log "Rendering <Message body=\"#{ message.body }\" />"
        message_classes = 'message box '
        message_classes += 'unread' if message.unread
        message_time = "posted this " + moment(message.time).fromNow()
        comments = `<Comments message={message} />`

        return `(
            <div className={message_classes}>
                <div className="main">
                    <div className="actions">
                        <a className={"comment " + (this.state.open ? 'selected': '')} onClick={this.toggleComments}>
                            <i className="fa fa-comment-o" />
                            <span>{message.comments.length ? message.comments.length + " Comments" : "Comment"}</span>
                        </a>
                    </div>
                    <Avatar src={message.user.avatar} />
                    <div className="details">
                        <span className="name">{message.user.name}</span>
                        <span className="time">{message_time}</span>
                    </div>
                    <div className="body">
                        <p>{message.body}</p>
                    </div>
                </div>
                {this.state.open ? comments : ''}
            </div>
        )`

window.NewMessage = React.createClass

    getInitialState: ->
        body: ''

    makeMessage: ->
        user:
            name: 'fred'
            avatar: 'http://avc.com/wp-content/uploads/2014/01/freds-avatar.jpg'
        body: @state.body
        time: new Date().getTime()
        comments: []

    addMessage: (e) ->
        e.preventDefault()
        MessagesDispatcher.addMessage @makeMessage()
        @setState body: ''

    updateBody: (e) ->
        e.preventDefault()
        @setState body: e.target.value

    render: ->
        `(
            <div className="box">
                <form onSubmit={this.addMessage}>
                    <input className="form-control" type="text"
                        placeholder="Post new message to this circle..."
                        value={this.state.body} onChange={this.updateBody}
                    />
                </form>
            </div>
        )`

window.Messages = React.createClass

    getInitialState: ->
        loading: true
        messages: []

    updateMessages: ->
        @setState
            loading: false
            messages: MessagesStore.messages

    componentWillMount: ->
        MessagesDispatcher.on 'update', @updateMessages

    loadMore: ->
        @setState loading: true
        MessagesDispatcher.loadMessages()

    render: ->
        messages = @state.messages.map (m) ->
            `<Message message={m} key={m.time} />`

        loader = `<Loader />`
        load_more = `(<a className="load-more" onClick={this.loadMore}>Load Older</a>)`

        return `(
            <div className="messages">
                {messages}
                {this.state.loading ? loader : load_more}
            </div>
        )`

React.render `<NewMessage />`, document.getElementById('new-message')
React.render `<Messages />`, document.getElementById('messages')
MessagesDispatcher.loadMessages()

