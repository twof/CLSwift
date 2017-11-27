# CLSwift
A Swift framework for writing commandline tools

### Inspiration
There are a large number of really useful commandline tools that work on Linux, but were never ported to macOS. One of those was `xdotool` which is a UI automation tool for things like typing and moving a mouse around. Something similar doesn't exist on macOS so I started porting it over with the intent to make a drop in replacement and called it `osxdotool`. `xdotool` is a large and very mature tool so the complexity got to me early on and I knew I needed a way to orginize everything coherently, but nothing that achieved that well IMO for Swift. `CLSwift` was born.

## Features
* Ingest and parse commandline input into `Arguments`, `Flags`, and the parameters associated with each
* Typecast parameters upfront according to expected input
* Validate input by expected number and type of parameters
* Built for modularity. Easily split up argument and flag definitions however you like
* Highly testible. Built to take in example input
* Generated help messages on command misuse

## Examples

### Flags
Flags are used to alter the functionality of an argument. This is done by getting a dictionary representing state from the argument and changing values within that dictionary. The closure parameter is executed when one of the  `argString`s is found in the commandline input and parameters are validated.

    let boolFlag = Flag<Bool>(argStrings: ["-f"],
                              help: "Replaces foo value with baz")
    { (params, state)  -> State in
        var newState = state
        newState["foo"] = "baz"
        return newState
    }

    let legsFlag = Flag<Int>(argStrings: ["-l, --legs"],
                             help: "Sets leg number of legs",
                             numArgs: .number(1))
    { (params, state) -> State in
        var newState = state
        newState["legs"] = params[0]
        return newState
    }

### Arguments
Just like `Flag`, the closure parameter is executed when one of the  `argString`s is found in the commandline input and parameters are validated. `Flag`s are attatched to an argument by passing them in on initialization. This is nice because if you have many arguments that use the same flag, you can reuse the exact same `Flag` instance.

    let arg = Argument<Int>(argStrings: ["hello"],
                            help: "Takes foo, hello and legs and does foobar",
                            state: ["foo": "bar", "hello": "world", "legs": 2],
                            numArgs: .number(2),
                            associatedArguments: [boolFlag, legsFlag])
    { (vals, state) in
        if state["foo"] as? String == "baz" {
            print("-f flag used")
        }
        if state["legs"] as? Int != 2 {
            print("-l flag used")
        }
    }
    
### Command Center
The following is the typical use case in which `CommandLine.arguments` is used for input, but you can also supply your own input for testing purposes by simply replacing `CommandLine.arguments` with your own array of strings.

The first step is figuring out which of your arguments was triggered if any. Then you call `.execute()` on that argument which executes the closure supplied on initialization.

`CommandCenter` takes your input and breaks it up into more usable objects which are stored in `commandCenter.input`.

    let commandCenter = CommandCenter(topLevelArgs: [arg], input: CommandLine.arguments)
    let triggeredCommand = commandCenter.check()

    if let triggeredCommand = triggeredCommand {
        triggeredCommand.execute(commandline: commandCenter.input)
    }
    
### Help message
The help message for the above looks like this

    Usage: hello <Int, Int> [options]

    Description:
    Takes foo, hello and legs and does foobar

    -f     Replaces foo value with baz
    -l <Int>    Sets leg number of legs

This could be triggered if no parameters where supplied for `-l` for example which would look like this

    hello 1 2 -f -l
