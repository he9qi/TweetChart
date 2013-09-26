/*
Module dependencies.
*/


(function() {
  var app, config, express, http, mock, mock_rankings_request, path, server;

  require("coffee-script");

  express = require("express");

  http = require("http");

  path = require("path");

  config = require('./config/options.coffee').parse(process.argv);

  app = express();

  server = http.createServer(app);

  require("./apps/socket-io")(app, server);

  app.set("port", process.env.PORT || 3000);

  app.set("views", __dirname + "/views");

  app.set("view engine", "jade");

  app.use(express.favicon());

  app.use(express.logger("dev"));

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(app.router);

  app.use(express["static"](path.join(__dirname, "public")));

  app.use(require("connect-assets")());

  if ("development" === app.get("env")) {
    app.use(express.errorHandler());
  }

  require("./apps/routes")(app);

  server.listen(app.get("port"), function() {
    return console.log("Express server listening on port " + app.get("port"));
  });

  mock_rankings_request = function() {
    return mock.post_rankings(app, function(error, data) {
      if (error) {
        return console.log(error);
      }
      return setTimeout(mock_rankings_request, 2000);
    });
  };

  if (config.mock) {
    console.log("======== mock rankings mode =========\n");
    mock = require('./config/mock.coffee');
    mock_rankings_request();
  }

}).call(this);
