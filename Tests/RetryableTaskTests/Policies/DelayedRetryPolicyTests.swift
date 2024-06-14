import Testing
import Foundation
@testable import RetryableTask

@Suite struct DelayedRetryPolicyTests {

    private let oneDelayInNanoseconds: UInt64 = 100_000_000
    private let oneDelayInSecond: TimeInterval = 0.1
    private let assertAccuracy: TimeInterval = 0.05 // 50 ms

    @Test func singleRetry() async throws {
        let start = Date()

        var policy = DelayedRetryPolicy(delay: oneDelayInNanoseconds, maxRetries: 1)
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration - oneDelayInSecond) < assertAccuracy)
    }

    @Test func dualRetry() async throws {
        let start = Date()

        var policy = DelayedRetryPolicy(delay: oneDelayInNanoseconds, maxRetries: 2)
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration - oneDelayInSecond * 2) < assertAccuracy)
    }

    @Test func noRetry() {
        let start = Date()

        let policy = DelayedRetryPolicy(delay: oneDelayInNanoseconds, maxRetries: 0)
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration) < assertAccuracy)
    }
}
