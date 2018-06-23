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
        class FlagState: StateType {
            var foo: String = "bar"
        }
        
        class OptionState: StateType {
            var legs: UInt = 2
        }
        
        let flag = Flag(
            triggers: ["-f"],
            help: "Replaces foo value with baz",
            state: FlagState()
        ) { state in
            XCTAssert(state.foo == "bar")
            let newState = state
            newState.foo = "baz"
            return newState
        }

        let legsOption = Option<UInt, OptionState>(
            triggers: ["-l"],
            help: "Sets leg number of legs",
            state: OptionState(),
            numParams: .number(1)
        ) { params, state in
            XCTAssert(state.legs == 2)
            XCTAssert(params.count == 1)
            XCTAssert(params == [1])
            let newState = state
            newState.legs = params[0]
            XCTAssert(newState.legs == 1)
            return newState
        }

        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo, hello and legs and does foobar",
            options: [flag, legsOption]
        ) { (vals, state) in
            if state.state(for: flag)?.foo  == "baz" {
                print("-f flag used")
            }
            if state.state(for: legsOption)?.legs != 2 {
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
        // TODO: I dislike classes being used for statetype because of the boilerplate, would much prefer to be able to use structs
        // potential solution: https://stackoverflow.com/questions/38885622/swift-protocol-extensions-property-default-values
        class FlagState: StateType {
            var foo: String = "bar"
        }
        
        class OptionState: StateType {
            var legs: UInt = 2
        }
        
        let option = Flag(
            triggers: ["-f"],
            help: "Replaces foo value with baz",
            state: FlagState()
        ) { state in
            XCTAssert(state.foo == "bar")
            let newState = state
            newState.foo = "baz"
            return newState
        }

        let legsOption = Option<UInt, OptionState>(
            triggers: ["-l"],
            help: "Sets leg number of legs",
            state: OptionState(),
            numParams: .number(1)
        ) { params, state in
            XCTFail()
            let newState = state
            newState.legs = params[0]
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
    
    func testIdealAPI() {
        class FlagState: StateType {
            var isOn: Bool
            
            init(isOn: Bool) {
                self.isOn = isOn
                super.init()
            }
        }
        let flag = Flag(
            triggers: ["-f"],
            help: "Toggles on",
            state: FlagState(isOn: false)
        ) { state -> FlagState in
            return FlagState(isOn: true)
        }
        
        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo and does foobar",
            numParams: .number(2),
            options: [flag]
        ) { vals, state in
            guard let flagState = state.state(for: flag) else {XCTFail(); fatalError()}
            
            XCTAssert(vals == [1, 2])
            XCTAssert(flagState.isOn == true)
        }
        
        // Should succeed
        let commandline = ["path/to/binary", "hello", "1", "2", "-f"]

        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()

        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testDoubleOptionTrigger() {
        class FlagState: StateType {
            var isOn: Bool
            
            init(isOn: Bool) {
                self.isOn = isOn
                super.init()
            }
        }
        
        var numberOfTriggers = 0
        
        let flag = Flag(
            triggers: ["-f"],
            help: "Toggles on",
            state: FlagState(isOn: false)
        ) { state -> FlagState in
            numberOfTriggers += 1
            XCTAssert(numberOfTriggers != 2)
            return FlagState(isOn: true)
        }
        
        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo and does foobar",
            numParams: .number(2),
            options: [flag]
        ) { vals, state in
            guard let flagState = state.state(for: flag) else {XCTFail(); fatalError()}
            
            XCTAssert(vals == [1, 2])
            XCTAssert(flagState.isOn == true)
        }
        
        // Should succeed
        let commandline = ["path/to/binary", "hello", "1", "2", "-f", "-f"]
        
        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testDoubleCommandTrigger() {
        class FlagState: StateType {
            var isOn: Bool
            
            init(isOn: Bool) {
                self.isOn = isOn
                super.init()
            }
        }
        
        let flag = Flag(
            triggers: ["-f"],
            help: "Toggles on",
            state: FlagState(isOn: false)
        ) { state -> FlagState in
            return FlagState(isOn: true)
        }
        
        var numberOfTriggers = 0
        
        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo and does foobar",
            numParams: .number(2),
            options: [flag]
        ) { vals, state in
            guard let flagState = state.state(for: flag) else {XCTFail(); fatalError()}
            
            numberOfTriggers += 1
            XCTAssert(numberOfTriggers != 2)
            
            XCTAssert(vals == [1, 2])
            XCTAssert(flagState.isOn == true)
        }
        
        // Should succeed
        let commandline = ["path/to/binary", "hello", "1", "2", "hello", "-f"]
        
        let commandCenter = CommandCenter(commands: [command], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
            XCTAssert(numberOfTriggers == 1)
        } else {
            XCTFail()
        }
    }
    
    func testMinimalUsage() {
        class FlagState: StateType {
            var isOn: Bool
            
            init(isOn: Bool=false) {
                self.isOn = isOn
                super.init()
            }
        }
        
        let flag = Flag(
            triggers: ["-f"],
            help: "Toggles on",
            state: FlagState()
        ) { state -> FlagState in
            return FlagState(isOn: true)
        }
        
        var numberOfTriggers = 0
        
        let command = Command<Int>(
            triggers: ["hello"],
            help: "Takes foo and does foobar",
            numParams: .number(2),
            options: [flag]
        ) { vals, state in
            guard let flagState = state.state(for: flag) else {XCTFail(); fatalError()}
            
            numberOfTriggers += 1
            XCTAssert(numberOfTriggers != 2)
            
            XCTAssert(vals == [1, 2])
            XCTAssert(flagState.isOn == true)
        }
        
        // Should succeed
        let commandline = ["path/to/binary", "hello", "1", "2", "-f"]
        
        CommandCenter(commands: [command], input: commandline).execute()
    }

    
    // Should not compile because `BadStateObject` doesn't conform to `StateType`
    // Doesn't compile
//    func testBadStateObject() {
//        class BadStateObject {
//
//        }
//
//        let flag = Flag(triggers: [], help: "", state: BadStateObject()) { state -> BadStateObject in
//            print("")
//            return BadStateObject()
//        }
//    }
}
