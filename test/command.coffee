require.paths.unshift __dirname + "/../lib"

command = require 'command'

# TODO add tests for run

exports.commandLine =
  'load options from config file': (test) ->
    test.expect 1

    options = command.loadConfigFile('test/fixtures/base/', {})
    test.deepEqual options.stitch.dependencies, ['ConsoleDummy.js'], 'should load list of dependencies'
    test.done()
