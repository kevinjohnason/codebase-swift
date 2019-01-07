import XCTest

import codebaseTests

var tests = [XCTestCaseEntry]()
tests += codebaseTests.allTests()
XCTMain(tests)