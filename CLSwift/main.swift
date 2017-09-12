//
//  main.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation
import Cocoa

typealias BoolType = Bool.Type

let getMouseLocation: Argument = Argument<Bool>(argStrings: ["getmouselocation"]) {_ in
    print(NSEvent.mouseLocation())
}

let mouseMove: Argument = Argument<Int>(argStrings: ["mousemove"], minNumArgs: 2) {args in
    print(args ?? "Improper arguments")
}

let commandCenter = CommandCenter(topLevelArgs: [
    getMouseLocation,
    mouseMove
    ])



let executedCommand = commandCenter.check()

if let executedCommand = executedCommand {
    executedCommand.execute()
}

