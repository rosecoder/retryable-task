/// Retry policy with a exponential increasing delay before each retry.
///
/// First try will wait for `minimumBackoffDelay`-nanoseconds (unless greater than `maximumBackoffDelay`).
///
/// Second try will wait for `minimumBackoffDelay * 2`-nanoseconds (unless greater than `maximumBackoffDelay`).
///
/// Third try will wait for `minimumBackoffDelay * 2 * 2`-nanoseconds (unless greater than `maximumBackoffDelay`).
///
/// - SeeAlso: `DelayedRetryPolicy`.
public struct ExponentialBackoffDelayRetryPolicy: RetryPolicy {

    /// Minimum delay in nanoseconds to use.
    ///
    /// - SeeAlso: `maximumBackoffDelay`.
    public let minimumBackoffDelay: UInt64

    /// Optional. Maximum delay in nanoseconds to use. Should be greater then `minimumBackoffDelay`.
    ///
    /// - SeeAlso: `minimumBackoffDelay`.
    public let maximumBackoffDelay: UInt64?

    /// Max number of retries that can be made.
    public let maxRetries: UInt

    private var tryIndex: UInt = 0
    private var nextDelay: UInt64

    /// Initializes a new policy with a exponential increasing delay before each retry.
    /// - Parameters:
    ///   - minimumBackoffDelay: Minimum delay in nanoseconds to use.
    ///   - maximumBackoffDelay: Optional. Maximum delay in nanoseconds to use. Should be greater then `minimumBackoffDelay`. Default `nil`.
    ///   - maxRetries: Max number of retries that can be made.
    public init(
        minimumBackoffDelay: UInt64,
        maximumBackoffDelay: UInt64? = nil,
        maxRetries: UInt
    ) {
        self.minimumBackoffDelay = minimumBackoffDelay
        self.maximumBackoffDelay = maximumBackoffDelay
        self.maxRetries = maxRetries

        self.nextDelay = minimumBackoffDelay
    }

    // MARK: - RetryPolicy

    /// `true` if a retry should be made, else `false`.
    public var shouldRetry: Bool {
        tryIndex < maxRetries
    }

    /// Call before each retry.
    public mutating func beforeRetry() async throws {
        try await Task.sleep(nanoseconds: nextDelay)

        tryIndex += 1

        if let maximumBackoffDelay = maximumBackoffDelay {
            nextDelay = min(nextDelay * 2, maximumBackoffDelay)
        } else {
            nextDelay *= 2
        }
    }
}
