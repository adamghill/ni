type
    Command* = ref object
        name*: string
        help*: string
        execute*: string
        longRunning*: bool
        requiresVirtualenv*: bool

type
    Config* = object
        filePath*: string
        disableDjangoManagementCommand*: bool
        pythonInterpreter*: string
        environmentFilePath*: string
        commands*: seq[Command]
        isVerbose*: bool
        runCommands*: bool
        dryRun*: bool
