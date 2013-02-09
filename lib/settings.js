var express = require('express')
  , everyauth = require('everyauth')
  , partials = require('express-partials')
  , fs = require('fs')

exports.boot = function (app){

  app.configure(function(){
    app.set('views', __dirname + '/../views')
    app.set('view engine', 'ejs')
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(function(req,res,next){res.header("X-powered-by", "Sharks");next()})
    app.use(require('connect-less')({ src: __dirname + '/../public/', compress: true, yuicompress: true }));
    app.use(require('./coffee-compile')({
      force: true,
      src: __dirname + '/../public',
      streamOut: true
    }));
    app.use(express.compress())
    app.use(express.static(__dirname + '/../public'))
    app.use(express.cookieParser('detta-är-en-hemlighet'))
    app.use(express.session({
      secret: 'c6b747964854ebfc8f1f8a42c232b6d3',
      cookie : { domain : 'jobs.'+app.config.COURSESHARK_DOMAIN },
      domain : 'jobs.'+app.config.COURSESHARK_DOMAIN,
      httpOnly : true,
      maxAge : 1000*60*60*24*5 // 5 days
    }))
    app.use(everyauth.middleware())

    // Helpers
    require('../lib/helpers').boot(app);
    // load the express-partials middleware
    app.use(partials());

    app.use(express.favicon())
    app.use(app.router)
  });

  app.set('showStackError', false)
  app.configure('development', function(){
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  })
  app.configure('staging', function(){
    app.enable('view cache')
  })
  app.configure('production', function(){
    app.enable('view cache')
  })

  try{
    gitHead = fs.readFileSync(__dirname+'/../.git/refs/remotes/origin/master', 'utf-8').trim();
    app.set('revision', gitHead)
  }catch(e){
    app.set('revision', 'r'+(new Date()).getTime())
  }
}