//
//  CommandCenter.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

public class CommandCenter {
    
    public var topLevelArgs: [ProtoArg]
    
    public init(topLevelArgs: [ProtoArg]) {
        self.topLevelArgs = topLevelArgs
    }
    
    public func check() -> ProtoArg? {
        for arg in self.topLevelArgs {
            let argStrings = arg.argStrings
            
            if argStrings.contains(CommandLine.arguments[1]) {
                return arg
            }
        }
        
        return nil
    }
}
