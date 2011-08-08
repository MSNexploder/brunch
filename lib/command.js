(function() {
  var banner, brunch, colors, dsl, fs, globalOpts, helpers, options, parser, path, usage, version, _;
  parser = require('nomnom');
  path = require('path');
  brunch = require('./brunch');
  helpers = require('./helpers');
  dsl = require('./dsl');
  colors = require('../vendor/termcolors').colors;
  fs = require('fs');
  _ = require('underscore');
  globalOpts = {
    version: {
      abbr: 'v',
      help: 'display brunch version',
      callback: function() {
        return version();
      }
    },
    output: {
      abbr: 'o',
      help: 'set build path',
      expectsValue: true,
      metavar: "DIRECTORY"
    },
    minify: {
      abbr: 'm',
      help: 'minify the app.js output via UglifyJS'
    }
  };
  banner = 'http://brunchwithcoffee.com\n\nUsage: brunch [command] [options]\n\nPossible commands are:\n  new [<path>]    create new brunch project\n  build [<path>]  build project\n  watch [<path>]  watch brunch directory and rebuild if something changed';
  options = {};
  exports.run = function() {
    if (process.argv[3] != null) {
      brunch.ROOT_PATH = process.argv[3];
    }
    parser.globalOpts(globalOpts);
    parser.scriptName('brunch <command> [<path>]');
    parser.printFunc(usage);
    parser.command('new').callback(function(opts) {
      var root_path;
      root_path = exports.generateRootPath(opts[1]);
      return brunch["new"](root_path, function() {
        options = exports.loadConfigFile(root_path, options);
        return brunch.build(root_path, options);
      });
    }).help('Create new brunch project');
    parser.command('build').callback(function(opts) {
      var root_path;
      root_path = exports.generateRootPath(opts[1]);
      options = exports.loadConfigFile(root_path, options);
      return brunch.build(root_path, options);
    }).help('Build a brunch project');
    parser.command('watch').callback(function(opts) {
      var root_path;
      root_path = exports.generateRootPath(opts[1]);
      options = exports.loadConfigFile(root_path, options);
      return brunch.watch(root_path, options);
    }).help('Watch brunch directory and rebuild if something changed');
    return parser.parseArgs();
  };
  exports.generateRootPath = function(appPath) {
    if (appPath != null) {
      return appPath;
    } else {
      return 'brunch/';
    }
  };
  exports.loadConfigFile = function(rootPath, options) {
    var coffee_config, yaml_config;
    options.rootPath = rootPath;
    coffee_config = path.join(rootPath, 'config.coffee');
    yaml_config = path.join(rootPath, 'config.yaml');
    if (path.existsSync(coffee_config)) {
      return dsl.loadConfigFile(coffee_config, options);
    } else if (path.existsSync(yaml_config)) {
      return dsl.loadYamlConfigFile(yaml_config, options);
    } else {
      helpers.log(colors.lred("brunch:   Couldn't find config.yaml file\n", true));
      return process.exit(0);
    }
  };
  usage = function() {
    process.stdout.write(banner);
    process.stdout.write(helpers.optionsInfo(globalOpts));
    return process.exit(0);
  };
  version = function() {
    process.stdout.write("brunch version " + brunch.VERSION + "\n");
    return process.exit(0);
  };
}).call(this);
