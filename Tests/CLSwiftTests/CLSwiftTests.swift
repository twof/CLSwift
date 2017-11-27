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
        let commandCenter = CommandCenter(topLevelArgs: [], input: ["path/to/binary"])
        let triggeredCommand = commandCenter.check()
        XCTAssert(triggeredCommand == nil)
    }
    
    
    func testLowerThanMinimumArgumentsInputLength() {
        let arg = Argument<Int>(argStrings: ["hello"], numArgs: .number(4)) { (result) in
            switch result {
            case .success(_):
                // Success is not expected
                XCTFail()
            case .error(let error):
                switch error {
                case InputError.tooFewArgs:
                    XCTAssert(true)// This error is expected
                default:
                    XCTFail()
                }
            }
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2"]
        
        let commandCenter = CommandCenter(topLevelArgs: [arg], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testGreaterThanMaximumArgumentsInputLength() {
        let arg = Argument<Int>(argStrings: ["hello"], numArgs: .number(1)) { (result) in
            switch result {
            case .success(_):
                // Success is not expected
                XCTFail()
            case .error(let error):
                switch error {
                case InputError.tooFewArgs:
                    XCTAssert(true)// This error is expected
                default:
                    XCTFail()
                }
            }
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2"]
        
        let commandCenter = CommandCenter(topLevelArgs: [arg], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testLessThanArgumentNumberRange() {
        let arg = Argument<Int>(argStrings: ["hello"], numArgs: .range(3..<5)) { (result) in
            switch result {
            case .success(_):
                // Success is not expected
                XCTFail()
            case .error(let error):
                switch error {
                case InputError.tooFewArgs:
                    XCTAssert(true)// This error is expected
                default:
                    XCTFail()
                }
            }
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2"]
        
        let commandCenter = CommandCenter(topLevelArgs: [arg], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
    
    func testWithAssociatedArg() {
        let flag = Flag<Bool>(argStrings: ["-f"]) { (params, state)  -> State in
            guard let foo = state["foo"] as? String else { XCTFail(); return [:] }
            XCTAssert(params == [])
            XCTAssert(foo == "bar")
            var newState = state
            newState["foo"] = "baz"
            return newState
        }
        
        let legsFlag = Flag<Int>(argStrings: ["-l"], numArgs: .number(1)) { (params, state) -> State in
            var newState = state
            newState["legs"] = params[0]
            return newState
        }
        
        let arg = Argument<Int>(argStrings: ["hello"], state: ["foo": "bar", "hello": "world", "legs": 2], associatedArguments: [flag, legsFlag]) { (result) in
            switch result {
            case .success(let vals, let state):
                XCTAssert(true)
            case .error(let error):
                switch error {
                case InputError.tooFewArgs:
                    XCTFail()
                default:
                    XCTFail()
                }
            }
        }
        
        let commandline = ["path/to/binary", "hello", "1", "2", "-f", "-l", "1"]
        
        let commandCenter = CommandCenter(topLevelArgs: [arg], input: commandline)
        let triggeredCommand = commandCenter.check()
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandCenter.input)
        } else {
            XCTFail()
        }
    }
}
