import parsetoml
import strutils
import utils
from objects import Command, Config
from terminal import fgGreen


const DefaultFilePath = ".dj-config.toml"

proc getOptVal(optParser: var auto, options: varargs[string], default: auto = nil): auto =
    result = default

    for option in options:
        for kind, key, val in optParser.getopt():
            if key == option:
                result = val
                break

    return

proc getOptExists(optParser: var auto, options: varargs[string], default: bool = false): bool =
    result = default

    for option in options:
        for kind, key, val in optParser.getopt():
            if key == option:
                result = true
                break

    return

proc parseConfigFile(filePath: string, config: var Config): Config =
    if ".toml" in filePath:
        let configFile = parsetoml.parseFile(filePath)
        if configFile.hasKey("disable_django_management_command"):
            config.disableDjangoManagementCommand = configFile["disable_django_management_command"].getBool()
        
        if configFile.hasKey("python_interpreter"):
            config.pythonInterpreter = configFile["python_interpreter"].getStr()

        if configFile.hasKey("environment_file_path"):
            config.environmentFilePath = configFile["environment_file_path"].getStr()

        for configCommand in configFile["commands"].getElems():
            let name = configCommand["name"].getStr()
            var command = Command(name: name, longRunning: false, requiresVirtualenv: false)        

            if configCommand.hasKey("help"):
                command.help = configCommand["help"].getStr()

            command.execute = configCommand["execute"].getStr()

            if configCommand.hasKey("longRunning"):
                command.longRunning = configCommand["longRunning"].getBool()
            
            if configCommand.hasKey("requiresVirtualenv"):
                command.requiresVirtualenv = configCommand["requiresVirtualenv"].getBool()
            
            config.commands.add(command)
    
    return config

proc getConfig*(optParser: var auto): Config =
    var filePath = getOptVal(optParser, "config", "c", default=DefaultFilePath)
    result = Config(filePath: filePath, runCommands: true, dryRun: false)
    result.isVerbose = getOptExists(optParser, ["verbose", "v"])

    if getOptExists(optParser, "version"):
        discard print(text="Version 0.0.1")
        result.runCommands = false

    result = parseConfigFile(filePath, result)

    if getOptExists(optParser, ["list", "l"]):
        for command in result.commands:
            discard print(text=command.name, fgColor=fgGreen)

            if command.help != "":
                discard print(text=command.help, indention="  ")

            discard print(text=command.execute, indention="  ")
            discard print(text="")

        result.runCommands = false
    
    if getOptExists(optParser, ["dry-run", "d"]):
        result.dryRun = true
    
    if getOptExists(optParser, ["help"]):
        discard print("""
Usage: nc [OPTIONS] [COMMAND_NAMES]...

  Run commands with :fire:

Options:
  -c, --config PATH: Specify the location of the config file (defaults to .dj-config.toml in the current directory).
  -l, --list: List the available custom commands and exits.
  -d, --dry_run: Shows what commands would be run without actually running them.
  -v, --verbose: Print out more verbose information.
  --version: Show the version and exit.
  --help: Show this message and exit.
""")
        result.runCommands = false

    return result
