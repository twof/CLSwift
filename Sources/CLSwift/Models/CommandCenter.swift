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
    
    public var commands: [ProtoCommand]
    public var input: [ArgumentEntity]
    
    public init(commands: [ProtoCommand], input: [String]=CommandLine.arguments) {
        self.commands = commands
        let processedInput = Array(input[1...]).group(by: { $0.hasPrefix(prefix: ["--", "-"])})
        self.input = processedInput.map { ArgumentEntity(command: $0.command, parameters: $0.arguments) }
    }
    
    public func check() -> ProtoCommand? {
        if input.count == 0 {return nil}

        for arg in self.commands {
            let argStrings = arg.triggers
            
            for argString in argStrings {
                guard input.index(where: { (token) -> Bool in
                    return token.command == argString
                }) != nil else {continue}
               
                return arg
            }
        }
        
        return nil
    }
}
