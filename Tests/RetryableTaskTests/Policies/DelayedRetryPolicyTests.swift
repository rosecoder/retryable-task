import XCTest
@testable import RetryableTask

final class DelayedRetryPolicyTests: XCTestCase {

    private let oneDelayInNanoseconds: UInt64 = 100_000_000
    private let oneDelayInSecond: TimeInterval = 0.1
    private let assertAccuracy: TimeInterval = 0.05 // 50 ms

    func testSingleRetry() async throws {
        let start = Date()

        var policy = DelayedRetryPolicy(delay: oneDelayInNanoseconds, maxRetries: 1)
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, oneDelayInSecond, accuracy: assertAccuracy)
    }

    func testDualRetry() async throws {
        let start = Date()

        var policy = DelayedRetryPolicy(delay: oneDelayInNanoseconds, maxRetries: 2)
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, oneDelayInSecond * 2, accuracy: assertAccuracy)
    }

    func testNoRetry() {
        let start = Date()

        let policy = DelayedRetryPolicy(delay: oneDelayInNanoseconds, maxRetries: 0)
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, 0, accuracy: assertAccuracy)
    }
}
