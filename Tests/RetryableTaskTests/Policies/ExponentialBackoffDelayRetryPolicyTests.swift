import Testing
import Foundation
@testable import RetryableTask

@Suite struct ExponentialBackoffDelayRetryPolicyTests {

    private let oneDelayInNanoseconds: UInt64 = 100_000_000
    private let oneDelayInSecond: TimeInterval = 0.1
    private let assertAccuracy: TimeInterval = 0.05 // 50 ms

    @Test func singleRetry() async throws {
        let start = Date()

        var policy = ExponentialBackoffDelayRetryPolicy(minimumBackoffDelay: oneDelayInNanoseconds, maxRetries: 1)
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration - oneDelayInSecond * 1) <= assertAccuracy)
    }

    @Test func trippleRetry() async throws {
        let start = Date()

        var policy = ExponentialBackoffDelayRetryPolicy(minimumBackoffDelay: oneDelayInNanoseconds, maxRetries: 3)
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 2 units
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 4 units
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration - oneDelayInSecond * 7) <= assertAccuracy)
    }

    @Test func trippleRetryWithMaxium() async throws {
        let start = Date()

        var policy = ExponentialBackoffDelayRetryPolicy(
            minimumBackoffDelay: oneDelayInNanoseconds,
            maximumBackoffDelay: oneDelayInNanoseconds * 2,
            maxRetries: 3
        )
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 1 unit
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 2 units
        #expect(policy.shouldRetry)

        try await policy.beforeRetry() // should wait 2 units
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration - oneDelayInSecond * 5) <= assertAccuracy)
    }

    @Test func noRetry() {
        let start = Date()

        let policy = ExponentialBackoffDelayRetryPolicy(minimumBackoffDelay: oneDelayInNanoseconds, maxRetries: 0)
        #expect(!policy.shouldRetry)

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        #expect(abs(duration) <= assertAccuracy)
    }
}
