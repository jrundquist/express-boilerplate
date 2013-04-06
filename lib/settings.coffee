express   = require 'express'
everyauth = require 'everyauth'
partials  = require 'express-partials'
fs        = require 'fs'
loggly    = require 'loggly'



exports.boot = (app) ->

  app.configure ()->


    app.loggly = loggly.createClient(
      subdomain: app.config.LOGGLY_SUBDOMAIN
      auth:
        username: app.config.LOGGLY_USERNAME
        password: app.config.LOGGLY_PASSWORD
      )

    app.log = (msg, callback) ->
      app.loggly.log(app.config.LOGGLY_INPUT, msg, callback)



    app.set 'views', __dirname + '/../views'

    app.set 'view engine', 'ejs'

    app.use express.bodyParser()

    app.use express.methodOverride()

    app.use (req,res,next) ->
      res.header("X-powered-by", "Sharks")
      next()

    app.use require('connect-less')(
      src: __dirname + '/../public/'
      compress: true
      yuicompress: true
    )

    app.use require('./coffee-compile')(
      force: true
      src: __dirname + '/../public'
      streamOut: true
    )

    app.use express.compress()

    app.use express.static __dirname + '/../public'

    app.use express.cookieParser 'detta-är-en-hemlighet'

    app.use express.session(
      secret: '43894d20bec9d6fb9e5e6ebae119e20c33feec50'
      cookie:
        domain: app.config.DOMAIN
      domain: app.config.DOMAIN
      httpOnly: true
      # 5 days
      maxAge: 1000*60*60*24*5
    )

    app.use everyauth.middleware()

    # Helpers
    (require '../lib/helpers').boot app

    # load the express-partials middleware
    app.use partials()

    app.use express.favicon()
    app.use app.router





  app.set 'showStackError', false


  # app.configure 'development', ()->
  #   app.use express.errorHandler
  #     dumpExceptions: true
  #     showStack: true


  app.configure 'staging', ()->
    app.enable 'view cache'


  app.configure 'production', ()->
    app.enable 'view cache'


  try
    gitHead = fs.readFileSync(__dirname+'/../.git/refs/remotes/origin/master', 'utf-8').trim()
    app.set 'revision', gitHead
  catch e
    app.set 'revision', 'r'+(new Date()).getTime()


