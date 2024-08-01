import Logging

#if swift(>=6.0)
public typealias Operation<Success: Sendable> = @isolated(any) () async throws -> Success
#else
public typealias Operation<Success: Sendable> = () async throws -> Success
#endif

/// Executes given operation with possible retries depending on given `RetryPolicy`.
///
/// Example usage:
///
///     withRetryableTask {
///         try consumeCoffee()
///     }
///
/// More complex example usage:
///
///     withRetryableTask(
///         policy: DelayedRetryPolicy(delay: 100_000_000, maxRetries: 2)
///     ) {
///         try consumeCoffee()
///     }
///
/// This will call the function `consumeCoffee()` 3 times with a delay of 100ms between
/// executions (unless the function succeedes on first or second try).
///
/// - Note: Task-cancellation is checked before each, *including the first*, execution.
///
/// - Parameters:
///   - policy: Retry policy to be used to determine if a retry should be made and when. Default `DefaultRetryPolicy`.
///   - logger: Optional logger to log failures with. Logs are made with warning-severity. Default `nil`.
///   - operation: The operation to execute with retries.
///
/// - Throws: Error thrown by the operation-parameter if no more retries are possible or a `CancellationError` if the task has been cancelled.
///
/// - Returns: Return element of the operation-parameter.
///
/// - SeeAlso: `DefaultRetryPolicy()`
public func withRetryableTask<Success: Sendable>(
    policy: RetryPolicy = DefaultRetryPolicy(),
    logger: Logger? = nil,
    operation: Operation<Success>,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) async throws -> Success {
    var policy = policy

    func doTry() async throws -> Success {

        // Cancelled?
        try Task.checkCancellation()

        do {
            // Try
            return try await operation()
        } catch {

            // Should we retry? If not, throw error we got
            guard await policy.shouldRetry else {
                throw error
            }

            // Log error as warning as we will do a retry
            logger?.warning("\(error)", file: file, function: function, line: line)

            // Inform polciy that a retry will be made
            try await policy.beforeRetry()

            // Try again
            return try await doTry()
        }
    }

    // Do first try!
    return try await doTry()
}
