//
//  CLSwiftTests.swift
//  CLSwift
//
//  Created by fnord on 9/13/17.
//
//

import XCTest

class CLSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmpty() {
        let commandCenter = CommandCenter(commands: [], input: ["path/to/binary"])
        let triggeredCommand = commandCenter.check()
        XCTAssert(triggeredCommand == nil)
    }
    
    
    func testLowerThanMinimumArgumentsInputLength() {
        let command = Command<Int>(triggers: ["hello"],
                                   help: "Does foo for bar",
                                   numArgs: .number(4))
        { (vals, state) in
            // Success is not expected
            XCTFail()
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2"]
        
        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testGreaterThanMaximumArgumentsInputLength() {
        let command = Command<Int>(triggers: ["hello"],
                                   help: "Does foo for bar",
                                   numArgs: .number(1))
        { (vals, state) in
            XCTFail()
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2"]
        
        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    //
    //    func testLessThanArgumentNumberRange() {
    //        let arg = Argument<Int>(argStrings: ["hello"], numArgs: .range(3..<5)) { (result) in
    //            switch result {
    //            case .success(_):
    //                // Success is not expected
    //                XCTFail()
    //            case .error(let error):
    //                switch error {
    //                case InputError.tooFewArgs:
    //                    XCTAssert(true)// This error is expected
    //                default:
    //                    XCTFail()
    //                }
    //            }
    //        }
    //
    //        let commandline = ["path/to/binary", "hello", "1", "2"]
    //
    //        let commandCenter = CommandCenter(topLevelArgs: [arg], input: commandline)
    //        let triggeredCommand = commandCenter.check()
    //
    //        if let triggeredCommand = triggeredCommand {
    //            triggeredCommand.execute(commandline: commandCenter.input)
    //        } else {
    //            XCTFail()
    //        }
    //    }
    //
    func testWithAssociatedArg() {
        let boolOption = Option<Bool>(triggers: ["-f"],
                                      help: "Replaces foo value with baz")
        { (params, state)  -> State in
            guard let foo = state["foo"] as? String else { XCTFail(); return [:] }
            XCTAssert(params == [])
            XCTAssert(foo == "bar")
            var newState = state
            newState["foo"] = "baz"
            return newState
        }
        
        let legsOption = Option<Int>(triggers: ["-l"],
                                     help: "Sets leg number of legs",
                                     numArgs: .number(1))
        { (params, state) -> State in
            var newState = state
            newState["legs"] = params[0]
            return newState
        }
        
        let command = Command<Int>(triggers: ["hello"],
                                   help: "Takes foo, hello and legs and does foobar",
                                   state: ["foo": "bar", "hello": "world", "legs": 2],
                                   associatedArguments: [boolOption, legsOption])
        { (vals, state) in
            if state["foo"] as? String == "baz" {
                print("-f flag used")
            }
            if state["legs"] as? Int != 2 {
                print("-l flag used")
            }
            XCTAssert(true)
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2", "-f", "-l", "1"]
        
        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testFailureWithFlags() {
        let option = Option<Bool>(triggers: ["-f"],
                                  help: "Replaces foo value with baz")
        { (params, state)  -> State in
            guard let foo = state["foo"] as? String else { XCTFail(); return [:] }
            XCTAssert(params == [])
            XCTAssert(foo == "bar")
            var newState = state
            newState["foo"] = "baz"
            return newState
        }
        
        let legsOption = Option<Int>(triggers: ["-l"],
                                     help: "Sets leg number of legs",
                                     numArgs: .number(1))
        { (params, state) -> State in
            var newState = state
            newState["legs"] = params[0]
            return newState
        }
        
        let command = Command<Int>(triggers: ["hello"],
                                   help: "Takes foo, hello and legs and does foobar",
                                   state: ["foo": "bar", "hello": "world", "legs": 2],
                                   numArgs: .number(2),
                                   associatedArguments: [option, legsOption])
        { (vals, state) in
            XCTFail()
        }
        
        // misuse of -l
        let commandline = ["path/to/binary", "hello", "1", "2", "-f", "-l"]
        
        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
}
