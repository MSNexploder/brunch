require.paths.unshift __dirname + "/../lib"

brunch  = require 'brunch'
fs      = require 'fs'
testCase = require('nodeunit').testCase
testHelpers = require './lib/testHelpers'

exports.newProject =
  default: testCase(
    setUp: (callback) ->
      brunch.new 'brunch', callback
    tearDown: (callback) ->
      testHelpers.removeDirectory 'brunch', callback
    'default': (test) ->
      test.expect 1
      brunchStat = fs.statSync 'brunch'
      test.strictEqual typeof(brunchStat), 'object', 'directory has been created'
      test.done()
  )
  nestedDirectories: testCase(
    setUp: (callback) ->
      brunch.new 'js/client', callback
    tearDown: (callback) ->
      testHelpers.removeDirectory 'js', callback
    'nested directory': (test) ->
      test.expect 1
      brunchStat = fs.statSync 'js/client/src'
      test.strictEqual typeof(brunchStat), 'object', 'directory provided by nested rootPath has been created'
      test.done()
  )
