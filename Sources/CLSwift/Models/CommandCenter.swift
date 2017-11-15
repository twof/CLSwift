//
//  CommandCenter.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation


/// Command could be a flag or a base command
/// Parameters could be an empty array in the case that there are no parameters
public struct ArgumentEntity {
    let command: String
    let parameters: [String]
}

public class CommandCenter {
    
    public var topLevelArgs: [ProtoArg]
    public var input: [ArgumentEntity]
    
    public init(topLevelArgs: [ProtoArg], input: [String]=CommandLine.arguments) {
        self.topLevelArgs = topLevelArgs
        let processedInput = Array(input[1...]).group(by: { $0.hasPrefix(prefix: ["--", "-"])})
        self.input = processedInput.map { ArgumentEntity(command: $0.command, parameters: $0.arguments) }
    }
    
    public func check() -> ProtoArg? {
        if input.count == 0 {return nil}

        for arg in self.topLevelArgs {
            let argStrings = arg.argStrings
            
            for argString in argStrings {
                guard let found = input.index(where: { (token) -> Bool in
                    return token.command == argString
                }) else {continue}
               
//                remainingInput = Array(remainingInput[(found+1)...])
                return arg
            }
        }
        
        return nil
    }
}
