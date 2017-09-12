//
//  CommandCenter.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

class CommandCenter {
    
    var topLevelArgs: [A]
    
    init(topLevelArgs: [A]) {
        self.topLevelArgs = topLevelArgs
    }
    
    func check() -> A? {
        for arg in self.topLevelArgs {
            let argStrings = arg.argStrings
            
            if argStrings.contains(CommandLine.arguments[1]) {
                return arg
            }
        }
        
        return nil
    }
}
