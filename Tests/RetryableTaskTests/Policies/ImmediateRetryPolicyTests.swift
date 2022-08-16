import XCTest
@testable import RetryableTask

final class ImmediateRetryPolicyTests: XCTestCase {
    
    func testSingleRetry() throws {
        var policy = ImmediateRetryPolicy(maxRetries: 1)
        XCTAssertTrue(policy.shouldRetry)

        policy.beforeRetry()
        XCTAssertFalse(policy.shouldRetry)
    }

    func testDualRetry() throws {
        var policy = ImmediateRetryPolicy(maxRetries: 2)
        XCTAssertTrue(policy.shouldRetry)

        policy.beforeRetry()
        XCTAssertTrue(policy.shouldRetry)

        policy.beforeRetry()
        XCTAssertFalse(policy.shouldRetry)
    }

    func testNoRetry() throws {
        let policy = ImmediateRetryPolicy(maxRetries: 0)
        XCTAssertFalse(policy.shouldRetry)
    }
}
