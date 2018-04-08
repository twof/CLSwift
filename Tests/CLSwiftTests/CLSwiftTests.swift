//
//  CLSwiftTests.swift
//  CLSwift
//
//  Created by fnord on 9/13/17.
//
//

import XCTest
@testable import CLSwift

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
        let command = Command<Int>(
            triggers: ["hello"],
           help: "Does foo for bar",
           numParams: .number(4)
        ) { (vals, state) in
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
        let command = Command<Int>(
            triggers: ["hello"],
           help: "Does foo for bar",
           numParams: .number(1)
        ) { (vals, state) in
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

    func testWithAssociatedArg() {
        let flag = Flag(
            triggers: ["-f"],
            help: "Replaces foo value with baz",
            state: ["foo": "bar"]
        ) { (state)  -> State in
            guard let foo = state["foo"] as? String else { XCTFail(); return [:] }
            XCTAssert(foo == "bar")
            var newState = state
            newState["foo"] = "baz"
            return newState
        }
        
        let legsOption = Option<Int>(
            triggers: ["-l"],
            help: "Sets leg number of legs",
            state: ["legs": 2],
            numParams: .number(1)
        ) { (params, state) -> State in
            var newState = state
            newState["legs"] = params[0]
            return newState
        }
        
        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo, hello and legs and does foobar",
            options: [flag, legsOption]
        ) { (vals, state) in
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
        let option = Flag(
            triggers: ["-f"],
            help: "Replaces foo value with baz",
            state: ["foo": "bar"]
        ) { (state)  -> State in
            guard let foo = state["foo"] as? String else { XCTFail(); return [:] }
            XCTAssert(foo == "bar")
            var newState = state
            newState["foo"] = "baz"
            return newState
        }
        
        let legsOption = Option<Int>(
            triggers: ["-l"],
            help: "Sets leg number of legs",
            state: ["legs": 2],
            numParams: .number(1)
        ) { (params, state) -> State in
            var newState = state
            newState["legs"] = params[0]
            return newState
        }
        
        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo, hello and legs and does foobar",
            numParams: .number(2),
            options: [option, legsOption]
        ) { (vals, state) in
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
