//
//  CommandCenter.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

class CommandCenter {
    var topLevelArgs: [Argument]!
    
    init(topLevelArgs: [Argument]) {
        self.topLevelArgs = topLevelArgs
    }
    
    func check() -> Argument? {
        for arg in self.topLevelArgs {
            if arg.argStrings.contains(CommandLine.arguments[1]) {
                return arg
            }
        }
        
        return nil
    }
}
