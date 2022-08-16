/// Retry policy with no retries.
///
/// This policy may feel useless, but can be used for unit tests where no retries should be made.
/// You can specify the default retry policy in the `setUp`-method in `XCTestCase`. For example:
///
///     class MyTests: XCTestCase {
///
///         override func setUp() {
///             super.setUp()
///
///             DefaultRetryPolicy.retryPolicy = NoRetryPolicy()
///         }
///     }
public struct NoRetryPolicy: RetryPolicy {

    /// Initializes a new policy with no retries.
    public init() {}

    // MARK: - RetryPolicy

    /// `true` if a retry should be made, else `false`.
    public var shouldRetry: Bool {
        false
    }

    /// Call before each retry.
    public func beforeRetry() {}
}
