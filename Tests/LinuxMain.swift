import XCTest
@testable import CLSwiftTests

extension CLSwiftTests {
    static var allTests: [(String, (CLSwiftTests) -> () throws -> Void)] = [
        ("testEmpty", testEmpty),
        ("testLowerThanMinimumArgumentsInputLength", testLowerThanMinimumArgumentsInputLength),
        ("testGreaterThanMaximumArgumentsInputLength", testGreaterThanMaximumArgumentsInputLength),
        ("testWithAssociatedArg", testWithAssociatedArg),
        ("testFailureWithFlags", testFailureWithFlags),
    ]
}

XCTMain([
    testCase(CLSwiftTests.allTests),
])
