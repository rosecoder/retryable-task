import XCTest
@testable import RetryableTask

final class DefaultRetryPolicyTests: XCTestCase {

    func testChangeDefault() async throws {

        // Change to policy: No retry
        do {
            DefaultRetryPolicy.retryPolicy = NoRetryPolicy()

            let policy = DefaultRetryPolicy()
            XCTAssertFalse(policy.shouldRetry)
        }

        // Change to policy: Immediate retry with single retry
        do {
            DefaultRetryPolicy.retryPolicy = ImmediateRetryPolicy(maxRetries: 1)

            var policy = DefaultRetryPolicy()
            XCTAssertTrue(policy.shouldRetry)

            try await policy.beforeRetry()
            XCTAssertFalse(policy.shouldRetry)
        }
    }
}
