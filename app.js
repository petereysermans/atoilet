
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes');

var app = module.exports = express();

// Configuration
app.configure(function(){
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));

  app.set("view options", {layout: false});

  app.engine('.html', function(str, options){
      return function(locals){
        return str;
      };
    }
  );
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes
app.get('/:page', routes.index);

require('./modules/toilet/routes.js')(app);

var port = process.env.PORT || 3000;

app.listen(port);
