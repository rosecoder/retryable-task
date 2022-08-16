/// Default retry policy which is a convenient wrapper around all other retry policies.
///
/// Change the default policy by setting the static `DefaultRetryPolicy.retryPolicy`-property.
/// For exmaple:
///
///     DefaultRetryPolicy.retryPolicy = DelayedRetryPolicy(delay: 100_000_000, maxRetries: 2)
///
/// A copy of the given retry policy will be made on each execution. Changing default policy will not effect currently running tasks.
public struct DefaultRetryPolicy: RetryPolicy {

    /// Policy to be used when `DefaultRetryPolicy` are used. Default `ImmediateRetryPolicy(maxRetries: 5)`.
    ///
    /// Changing default policy will not effect currently running tasks.
    public static var retryPolicy: RetryPolicy = ImmediateRetryPolicy(maxRetries: 5)

    private var retryPolicy: RetryPolicy

    /// Initializes a new policy with a copy of the currently set default policy.
    ///
    /// - SeeAlso: `DefaultRetryPolicy.retryPolicy`.
    public init() {
        self.retryPolicy = Self.retryPolicy
    }

    // MARK: - RetryPolicy

    /// `true` if a retry should be made, else `false`.
    public var shouldRetry: Bool {
        retryPolicy.shouldRetry
    }

    /// Call before each retry.
    public mutating func beforeRetry() async throws {
        try await retryPolicy.beforeRetry()
    }
}
