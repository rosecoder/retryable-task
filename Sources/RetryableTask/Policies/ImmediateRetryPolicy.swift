/// Retry policy with a immediate (no delay) retry.
///
/// - SeeAlso: `DelayedRetryPolicy`.
public struct ImmediateRetryPolicy: RetryPolicy {

    /// Max number of retries that can be made.
    public let maxRetries: UInt

    private var tryIndex: UInt = 0

    /// Initializes a new policy with a immediate (no delay) retry.
    /// - Parameters:
    ///   - maxRetries: Max number of retries that can be made.
    public init(maxRetries: UInt) {
        self.maxRetries = maxRetries
    }

    // MARK: - RetryPolicy

    /// `true` if a retry should be made, else `false`.
    public var shouldRetry: Bool {
        tryIndex < maxRetries
    }

    /// Call before each retry.
    public mutating func beforeRetry() {
        tryIndex += 1
    }
}
