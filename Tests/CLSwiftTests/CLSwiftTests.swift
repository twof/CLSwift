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
        let commandCenter = CommandCenter(topLevelArgs: [])
        let triggeredCommand = commandCenter.check(input: ["path/to/binary"])
        XCTAssert(triggeredCommand == nil)
    }
    
    
    func testLowerThanMinimumArgumentsInputLength() {
        let arg = Argument<Int>(argStrings: ["hello"], minNumArgs: 4) { (result) in
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
        
        let commandCenter = CommandCenter(topLevelArgs: [arg])
        let triggeredCommand = commandCenter.check(input: commandline)
        
        if let triggeredCommand = triggeredCommand {
            triggeredCommand.execute(commandline: commandline)
        } else {
            XCTFail()
        }
    }
}
