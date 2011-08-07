var util = require('util');
var path = require('path');
var port = process.argv[2];
var rootPath = process.argv[3];

var express = require("express");
var app = express.createServer();

app.configure(function(){
    app.use(express.static(rootPath));
    // setup views to render index.html
    app.set('views', rootPath);
    app.set('view options', { layout: false });
    app.register('.html', require('eco'));
});

app.get('/', function(req, res){
  res.render('index.html');
});

app.listen(parseInt(port, 10));
