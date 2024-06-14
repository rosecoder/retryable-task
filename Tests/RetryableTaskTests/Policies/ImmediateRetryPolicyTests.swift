import Testing
@testable import RetryableTask

@Suite struct ImmediateRetryPolicyTests {

    @Test func singleRetry() throws {
        var policy = ImmediateRetryPolicy(maxRetries: 1)
        #expect(policy.shouldRetry)

        policy.beforeRetry()
        #expect(!policy.shouldRetry)
    }

    @Test func dualRetry() throws {
        var policy = ImmediateRetryPolicy(maxRetries: 2)
        #expect(policy.shouldRetry)

        policy.beforeRetry()
        #expect(policy.shouldRetry)

        policy.beforeRetry()
        #expect(!policy.shouldRetry)
    }

    @Test func noRetry() throws {
        let policy = ImmediateRetryPolicy(maxRetries: 0)
        #expect(!policy.shouldRetry)
    }
}
