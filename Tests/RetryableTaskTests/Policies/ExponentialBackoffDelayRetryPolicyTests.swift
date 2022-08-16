import XCTest
@testable import RetryableTask

final class ExponentialBackoffDelayRetryPolicyTests: XCTestCase {

    private let oneDelayInNanoseconds: UInt64 = 100_000_000
    private let oneDelayInSecond: TimeInterval = 0.1
    private let assertAccuracy: TimeInterval = 0.05 // 50 ms

    func testSingleRetry() async throws {
        let start = Date()

        var policy = ExponentialBackoffDelayRetryPolicy(minimumBackoffDelay: oneDelayInNanoseconds, maxRetries: 1)
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, oneDelayInSecond * 1, accuracy: assertAccuracy)
    }

    func testTrippleRetry() async throws {
        let start = Date()

        var policy = ExponentialBackoffDelayRetryPolicy(minimumBackoffDelay: oneDelayInNanoseconds, maxRetries: 3)
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 2 units
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 4 units
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, oneDelayInSecond * 7, accuracy: assertAccuracy)
    }

    func testTrippleRetryWithMaxium() async throws {
        let start = Date()

        var policy = ExponentialBackoffDelayRetryPolicy(
            minimumBackoffDelay: oneDelayInNanoseconds,
            maximumBackoffDelay: oneDelayInNanoseconds * 2,
            maxRetries: 3
        )
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 2 units
        XCTAssertTrue(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 2 units
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, oneDelayInSecond * 5, accuracy: assertAccuracy)
    }

    func testNoRetry() {
        let start = Date()

        let policy = ExponentialBackoffDelayRetryPolicy(minimumBackoffDelay: oneDelayInNanoseconds, maxRetries: 0)
        XCTAssertFalse(policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        XCTAssertEqual(duration, 0, accuracy: assertAccuracy)
    }
}
