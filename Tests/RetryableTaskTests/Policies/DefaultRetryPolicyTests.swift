import XCTest
@testable import RetryableTask

final class DefaultRetryPolicyTests: XCTestCase {

    func testChangeDefault() async throws {

        // Change to policy: No retry
        do {
            await DefaultRetryPolicyConfiguration.shared.use(retryPolicy: NoRetryPolicy())

            var policy = DefaultRetryPolicy()
            let shouldRetry = await policy.shouldRetry
            XCTAssertFalse(shouldRetry)
        }

        // Change to policy: Immediate retry with single retry
        do {
            await DefaultRetryPolicyConfiguration.shared.use(retryPolicy: ImmediateRetryPolicy(maxRetries: 1))

            var policy = DefaultRetryPolicy()
            var shouldRetry = await policy.shouldRetry
            XCTAssertTrue(shouldRetry)

            try await policy.beforeRetry()
            shouldRetry = await policy.shouldRetry
            XCTAssertFalse(shouldRetry)
        }
    }
}
