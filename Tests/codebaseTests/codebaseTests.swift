import XCTest
@testable import codebase

final class codebaseTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(codebase().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
