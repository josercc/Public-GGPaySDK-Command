import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Public_GGPaySDKTests.allTests),
    ]
}
#endif
