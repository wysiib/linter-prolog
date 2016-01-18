path = require 'path'
child_process = require 'child_process'

module.exports = class LinterProvider
  swi_regex = ///
    (\w+):  #The type of issue being reported.
    \s+     #A space.
    (\S+):  #The file with issue.
    (\d+):  #The line number with issue.
    (\d+):  #The column number with issue.
    \s+     #A space.
    (.*)    #A message explaining the issue at hand.
  ///

  getCommand = ->
    plpath = atom.config.get('linter-prolog.compilerPath', [])
    if plpath.indexOf("swi") > -1
      "#{atom.config.get 'linter-prolog.compilerPath'} -g \"halt.\" -l"
    else
      "#{atom.config.get 'linter-prolog.compilerPath'} --goal \"halt.\" -l"

  getCommandWithFile = (file) -> "#{getCommand()} #{file}"

  parse = (line) ->
    if line.match swi_regex
      [type, file, line, column, message] = line.match(swi_regex)[1..5]
      return [file, line, column, type, message]
    lines = line.split("\n")
    if lines[0].endsWith("error")
      message = lines[1].substring(2)
      file = lines[lines.length-2]
      file = file.substring(file.indexOf("'")+1, file.length-1)
      line = lines[2].substring(9)
      return [file, line, 0, "Error", message]


  lint: (TextEditor) ->
    new Promise (Resolve) ->
      file = path.basename TextEditor.getPath()
      cwd = path.dirname TextEditor.getPath()
      data = []
      command = getCommandWithFile file
      console.log "Linter Command: #{command}"
      process = child_process.exec command, {cwd: cwd}
      process.stderr.on 'data', (d) -> data.push d.toString()
      process.on 'close', ->
        toReturn = []
        for line in data
          console.log "Prolog Linter Provider: #{line}"
          parse_result = parse(line)
          if(parse_result?)
            [file, line, column, type, message] = parse_result
            toReturn.push(
              type: type,
              text: message,
              filePath: file.normalize()
              range: [[line - 1, column - 1], [line - 1, column - 1]]
            )
        Resolve toReturn
