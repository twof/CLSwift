//
//  Option.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

protocol HasParams {
    associatedtype ParamType
    var params: [ParamType] {get}
}

class Argument {
    var argStrings: [String]
    var required: Bool
    
    var execute: () -> ()
    
    init(argStrings: [String], required: Bool=false, onExecution: @escaping () -> ()) {
        self.argStrings = argStrings
        self.required = required
        
        self.execute = onExecution
    }
    
    func exists(params: [String]) -> Bool {
        for argString in argStrings {
            if params.contains(argString) {
                return true
            }
        }
        
        return false
    }
}

class BooleanArgument: Argument {
    
}
