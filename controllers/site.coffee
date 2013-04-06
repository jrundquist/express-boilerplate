exports = module.exports = (app) ->
  # Home
  app.get '/', (req, res) ->
    res.render 'index'
