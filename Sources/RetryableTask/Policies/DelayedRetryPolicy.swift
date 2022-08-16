/// Retry policy with a static delay before each retry.
///
/// - SeeAlso: `ExponentialBackoffDelayRetryPolicy`.
public struct DelayedRetryPolicy: RetryPolicy {

    /// Delay in nanoseconds to use before each retry.
    public let delay: UInt64

    /// Max number of retries that can be made.
    public let maxRetries: UInt

    private var tryIndex: UInt = 0

    /// Initializes a new policy with a static delay before each retry.
    /// - Parameters:
    ///   - delay: Delay in nanoseconds to use before each retry.
    ///   - maxRetries: Max number of retries that can be made.
    public init(delay: UInt64, maxRetries: UInt) {
        self.delay = delay
        self.maxRetries = maxRetries
    }

    // MARK: - RetryPolicy

    /// `true` if a retry should be made, else `false`.
    public var shouldRetry: Bool {
        tryIndex < maxRetries
    }

    /// Call before each retry.
    public mutating func beforeRetry() async throws {
        try await Task.sleep(nanoseconds: delay)

        tryIndex += 1
    }
}
