/// A policiy to be used along with `withRetryableTask()`. Defines logic for when retry should be made.
///
/// Built-in policies are:
/// - `DefaultRetryPolicy`
/// - `ImmediateRetryPolicy`
/// - `DelayedRetryPolicy`
/// - `ExponentialBackoffDelayRetryPolicy`
/// - `NoRetryPolicy`
public protocol RetryPolicy: Sendable {

    /// `true` if a retry should be made, else `false`. Called before every execution except the first one.
    var shouldRetry: Bool { mutating get async }

    /// Informs the policy that a retry will be made. Called before every exeyction except the first one.
    mutating func beforeRetry() async throws
}
