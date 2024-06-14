import Testing
@testable import RetryableTask

@Suite(.serialized)
struct DefaultRetryPolicyTests {

    @Test func changeDefault() async throws {

        // Change to policy: No retry
        do {
            await DefaultRetryPolicyConfiguration.shared.use(retryPolicy: NoRetryPolicy())

            var policy = DefaultRetryPolicy()
            #expect(!(await policy.shouldRetry))
        }

        // Change to policy: Immediate retry with single retry
        do {
            await DefaultRetryPolicyConfiguration.shared.use(retryPolicy: ImmediateRetryPolicy(maxRetries: 1))

            var policy = DefaultRetryPolicy()
            #expect(await policy.shouldRetry)

            try await policy.beforeRetry()
            #expect(!(await policy.shouldRetry))
        }
    }
}
