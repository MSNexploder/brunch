fs        = require 'fs'
path      = require 'path'
helpers   = require '../helpers'
colors    = require('../../vendor/termcolors').colors
stylus    = require 'stylus'
brunch    = require '../brunch'

Compiler = require('./base').Compiler

try
  nib = require('nib')()
catch error
  false

class exports.StylusCompiler extends Compiler

  filePattern: ->
    @options.stylus.filePattern

  compile: (files) ->
    mainFilePath = path.join(@options.rootPath, 'src/app/styles/main.styl')

    fs.readFile(mainFilePath, 'utf8', (err, data) =>
      if err?
        helpers.log colors.lred('stylus err: ' + err)
      else
        compiler = stylus(data)
          .set('filename', mainFilePath)
          .set('compress', true)
          .include(path.join(@options.rootPath, 'src'))

        if nib
          compiler.use nib

        compiler.render (err, css) =>
          if err?
            helpers.log colors.lred('stylus err: ' + err)
          else
            fs.writeFile(@options.stylus.output, css, 'utf8', (err) =>
              if err?
                helpers.log colors.lred('stylus err: ' + err)
              else
                helpers.log "stylus:   #{colors.green('compiled', true)} main.css\n"
            )
    )
