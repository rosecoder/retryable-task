import XCTest
@testable import RetryableTask

final class NoRetryPolicyTests: XCTestCase {

    func testNoRetry() throws {
        let policy = NoRetryPolicy()
        XCTAssertFalse(policy.shouldRetry)

        policy.beforeRetry() // Should do nothing
    }
}
