import Testing
@testable import RetryableTask

@Suite struct NoRetryPolicyTests {

    @Test func noRetry() throws {
        let policy = NoRetryPolicy()
        #expect(!policy.shouldRetry)

        policy.beforeRetry() // Should do nothing
    }
}
