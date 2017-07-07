//
//  main.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation
import Cocoa

let getMouseLocation: Argument = BooleanArgument(argStrings: ["getmouselocation"]) { 
    print(NSEvent.mouseLocation())
}

let commandCenter = CommandCenter(topLevelArgs: [
    getMouseLocation
    ])

if let executedCommand = commandCenter.check() {
    executedCommand.execute()
}

