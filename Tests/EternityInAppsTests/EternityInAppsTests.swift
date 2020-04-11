import XCTest
@testable import EternityInApps

final class EternityInAppsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssert(IAPProducts.purchaseProductIdentifiers.isEmpty)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
