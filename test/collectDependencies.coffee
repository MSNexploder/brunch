require.paths.unshift __dirname + "/../lib"

testCase = require('nodeunit').testCase
path = require 'path'
StitchCompiler = require('compilers').StitchCompiler

module.exports = testCase(
  'collect brunch dependencies': (test) ->
    test.expect 1

    options =
      rootPath: 'test/fixtures/base'
      dependencies: [
        'ConsoleDummy.js'
        'jquery-1.6.2.js'
        'underscore-1.1.7.js'
        'backbone-0.5.2.js'
      ]

    compiler = new StitchCompiler options

    dependencyPaths = compiler.collectDependencies()
    test.deepEqual dependencyPaths, [
      path.resolve('test/fixtures/base/src/vendor/ConsoleDummy.js'),
      path.resolve('test/fixtures/base/src/vendor/jquery-1.6.2.js'),
      path.resolve('test/fixtures/base/src/vendor/underscore-1.1.7.js'),
      path.resolve('test/fixtures/base/src/vendor/backbone-0.5.2.js')
    ]
    test.done()

  'collect brunch dependencies and backbone-localstorage - it should ignore dotfiles and directories': (test) ->
    test.expect 1

    options =
      rootPath: 'test/fixtures/base'
      dependencies: [
        'ConsoleDummy.js'
        'jquery-1.6.2.js'
        'underscore-1.1.7.js'
        'backbone-0.5.2.js'
        'backbone-localstorage.js'
      ]

    compiler = new StitchCompiler options
    compiler.vendorPath = '../alternate_vendor'

    dependencyPaths = compiler.collectDependencies()
    test.deepEqual dependencyPaths, [
      path.resolve('test/fixtures/alternate_vendor/ConsoleDummy.js'),
      path.resolve('test/fixtures/alternate_vendor/jquery-1.6.2.js'),
      path.resolve('test/fixtures/alternate_vendor/underscore-1.1.7.js'),
      path.resolve('test/fixtures/alternate_vendor/backbone-0.5.2.js'),
      path.resolve('test/fixtures/alternate_vendor/backbone-localstorage.js')
    ]
    test.done()
)
