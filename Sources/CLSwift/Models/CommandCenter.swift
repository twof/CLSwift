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
    
    public func check(input: [String]=CommandLine.arguments) -> ProtoArg? {
        if input.count <= 1 {return nil}

        for arg in self.topLevelArgs {
            let argStrings = arg.argStrings
            
            if argStrings.contains(input[1]) {
                return arg
            }
        }
        
        return nil
    }
}
