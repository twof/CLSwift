//
//  Option.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

public protocol ProtoArg {
    var argStrings: [String] {get set}
    var type: LosslessStringConvertible.Type {get set}
    
    func execute(commandline: [String])
    func execute()
}

public class Argument<U: LosslessStringConvertible>: ProtoArg {
    public var type: LosslessStringConvertible.Type = U.self
    public var argStrings: [String]
    var associatedArguments: [Argument]?
    var required: Bool
    var location: Int?
    var minNumArgs: Int
    
    var onExecution: (Result<[U]>) -> ()
    
    public init(argStrings: [String], minNumArgs: Int=0, required: Bool=false, associatedArguments: [Argument]?=nil, onExecution: @escaping (Result<[U]>) -> ()) {
        self.argStrings = argStrings
        self.required = required
        self.minNumArgs = minNumArgs
        
        self.associatedArguments = associatedArguments
        
        self.onExecution = onExecution
    }
    
    func existsAt(params: [String]) -> Int? {
        for argString in argStrings {
            if let location = params.index(of: argString) {
                return location
            }
        }
        
        return nil
    }
    
    public func execute() {
        self.execute(commandline: CommandLine.arguments)
    }
    
    public func execute(commandline: [String]=CommandLine.arguments) {
    
        if commandline.count - 1 < self.minNumArgs {
            return onExecution(.error(InputError.tooFewArgs))
        }
        
        self.location = existsAt(params: commandline)
        
        guard let location = self.location else {return onExecution(.error(InputError.argumentNotFound))}
        
        let args: [U?] = commandline[location+1...minNumArgs+location].map { (arg) -> U? in
            if let casted = convert(value: arg, type: U.self) {
                return casted
            }else{
                return nil
            }
        }
        
        if args.contains(where: { (item) -> Bool in
            return item == nil
        }) {
            return onExecution(Result.error(InputError.invalidType("Could not cast one of the parameters to the specified type: \(U.self)")))
        }else{
            return onExecution(Result.success((args as! [U])))
        }
    }
    
    private func convert<T: LosslessStringConvertible>(value: String, type: T.Type) -> T? {
        return T.self.init(value)
    }
}
