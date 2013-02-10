
exports.boot = (app) ->
  app.use (req, res, next) ->
    res.status 404

    # respond with html page
    if req.accepts 'html'
      return res.render 'errors/index',
        url: req.url
        status: 404
        title: "Missing"
        error: "It seems that page is gone."

    # respond with json
    if req.accepts 'json'
      return res.send error: 'Not found'

    # default to plain-text. send()
    res.type('txt').send('Not found')