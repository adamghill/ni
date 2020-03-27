import os
import osproc
import parseopt
import utils
from config_loader import getConfig
from objects import Command, Config
from terminal import fgYellow


var optParser = initOptParser()
let config = getConfig(optParser)

var commandArguments: seq[string]

if config.runCommands:
    for kind, key, val in optParser.getopt():
        if kind == cmdArgument:
            commandArguments.add(key)



for commandArgument in commandArguments:
    if config.isVerbose:
        echo "Look for ", commandArgument

    var foundCommandArgument = false

    for command in config.commands:
        if command.name == commandArgument:
            if config.isVerbose:
                echo "Found ", commandArgument, " command"

            foundCommandArgument = true

            if command.requiresVirtualenv and not existsEnv("VIRTUAL_ENV"):
                discard print("Skip " & commandArgument & " because a virtual environment could not be found...", fgColor=fgYellow)
                continue

            # move this outside the loop
            if config.dryRun:
                echo "Run process: \"", command.execute, "\""
            else:
                var process = startProcess(command.execute, options={poParentStreams, poStdErrToStdOut, poInteractive, poEvalCommand})
                discard process.waitForExit()
                process.close()
    
    if not foundCommandArgument:
        var process = startProcess(commandArgument, options={poParentStreams, poStdErrToStdOut, poInteractive, poEvalCommand})
        discard process.waitForExit()
        process.close()

discard exit()
