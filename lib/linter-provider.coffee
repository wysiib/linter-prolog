path = require 'path'
child_process = require 'child_process'

module.exports = class LinterProvider
  swi_regex = ///
    (\w+):  #The type of issue being reported.
    \s+     #A space.
    [^\:]+:  #The file with issue.
    (\d+):  #The line number with issue.
    ((\d+):)?  #The column number with issue.
    \s+     #A space.
    (.*)    #A message explaining the issue at hand.
  ///

  getParameters = (file) ->
    plpath = atom.config.get('linter-prolog.compilerPath', [])
    if plpath.indexOf("swi") > -1
      return ['-g', "halt.", '-l', "#{file}"]
    else
      return ['--goal', "halt.", '-l',  "#{file}"]

  parse = (line) ->
    match = line.match swi_regex
    if match
      return {
        type: match[1]
        line: match[2]
        column: match[4] ? 1
        text: match[5]
      }

    lines = line.split("\n")
    if lines[0].endsWith("error")
      return {
        type: "Error"
        line: lines[2].substring(9)
        column: 1
        text: lines[1].substring(2)
      }


  lint: (TextEditor) ->
    helpers = require('atom-linter')
    new Promise (Resolve) ->
      file = TextEditor.getPath()
      data = []
      command = atom.config.get('linter-prolog.compilerPath', [])
      console.log "Linter Command: #{command}"
      parameters = getParameters(file)
      console.log "Linter Parameters: #{parameters}"

      return helpers.exec(command, parameters, {stream: "both"}).then (output) ->
        toReturn = []
        console.log "Prolog Linter Provider: #{output.stderr}"
        parse_result = parse(output.stderr)
        if(parse_result?)
          line = parse_result.line
          col = parse_result.column
          toReturn.push(
            severity: parse_result.type.toLowerCase()
            excerpt: parse_result.text
            location: {
              file: TextEditor.getPath()
              position: [[line-1, col-1], [line-1, col-1]]
            }
         )
         Resolve toReturn
