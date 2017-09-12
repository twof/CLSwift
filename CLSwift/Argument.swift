//
//  Option.swift
//  CLSwift
//
//  Created by fnord on 7/7/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

//protocol HasAssociatedArguments {
//    associatedtype ParamType
//    var params: [ParamType] {get}
//    var associatedArguments: [Argument<Any>] {get}
//}
protocol A {
    var argStrings: [String] {get set}
    var type: LosslessStringConvertible.Type {get set}
    
    func execute()
}

class Argument<U: LosslessStringConvertible>: A {
    var type: LosslessStringConvertible.Type = U.self
    var argStrings: [String]
    var associatedArguments: [Argument]?
    var required: Bool
    var location: Int?
    var minNumArgs: Int
    
    var onExecution: ([U]?) -> ()
    
    init(argStrings: [String], minNumArgs: Int=0, required: Bool=false, associatedArguments: [Argument]?=nil, onExecution: @escaping ([U]?) -> ()) {
        self.argStrings = argStrings
        self.required = required
        self.minNumArgs = minNumArgs
        
        self.associatedArguments = associatedArguments
        
        self.onExecution = onExecution
    }
    
    func existsAt(params: [String]) -> Int? {
        for argString in argStrings {
            if let location = params.index(of: argString) {
//                self.location = location
                return location
            }
        }
        
        return nil
    }
    
    func execute(){
        let commandline = CommandLine.arguments
        
        self.location = existsAt(params: commandline)
        
        guard let location = self.location else {onExecution(nil); return}
        
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
            onExecution(nil)
        }else{
            onExecution((args as! [U]))
        }
    }
    
    private func convert<T: LosslessStringConvertible>(value: String, type: T.Type) -> T? {
        return T.self.init(value)
    }
    
    func translate(arg: A) -> Argument {
        return arg as! Argument<U>
    }
}

//class BooleanArgument: Argument {
//    
//}
//
//class IntArgument: Argument, HasAssociatedArguments {
//    typealias ParamType = Int
//    
//    var params: [Int]
//    var associatedArguments: [Argument]
//
//    init(argStrings: [String], required: Bool=false, onExecution: @escaping () -> (), ) {
//        <#statements#>
//    }
//}
