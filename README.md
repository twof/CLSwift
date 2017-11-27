# CLSwift
A Swift framework for writing commandline tools

### Inspiration
There are a large number of really useful commandline tools that work on Linux, but were never ported to macOS. One of those was `xdotool` which is a UI automation tool for things like typing and moving a mouse around. Something similar doesn't exist on macOS so I started porting it over with the intent to make a drop in replacement and called it `osxdotool`. `xdotool` is a large and very mature tool so the complexity got to me early on and I knew I needed a way to orginize everything coherently, but nothing that achieved that well IMO for Swift. `CLSwift` was born.

## Features
* Ingest and parse commandline input into `Arguments`, `Flags`, and the parmaegers associated with each
* Typecast parameters upfront according to expected input
* Validate input by expected number and type of parameters
* Built for modularity. Easily split up argument and flag definitions however you like
* Highly testible. Built to take in example input
