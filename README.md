# RetryableTask

RetryableTask includes a single global function called `withRetryableTask` which executes a given operation with retries. Retries are determined by a given `RetryPolicy`.

The following example will execute a `consumeCoffee`-function until it succeeds, with a relay of 100ms, and a maximum of 3 attempts. ☕️

```swift
withRetryableTask(policy: DelayedRetryPolicy(delay: 100_000_000, maxRetries: 2)) {
    try consumeCoffee()
}
```

## Installation

Using Swift Package Manager:

```
…
dependencies: [
    .package(url: "https://github.com/rosecoder/retryable-task.git", from: "1.0.0"),
],
…
targets: [
    .target(name: "YourProduct", dependencies: [
        .product(name: "RetryableTask", package: "retryable-task")
    ]),
]
```

## Examples

### Setting default policy

A default policy can be set by setting the static `DefaultRetryPolicy.retryPolicy` property. For example:

```swift
DefaultRetryPolicy.retryPolicy = DelayedRetryPolicy(delay: 100_000_000, maxRetries: 2)
```

This will use the new default retry policy for all calls to `withRetryableTask` which does not define a policy.

### Using `ImmediateRetryPolicy`

`ImmediateRetryPolicy` is a retry policy with a immediate (no delay) before each retry.

Example:

```swift
DefaultRetryPolicy.retryPolicy = ImmediateRetryPolicy(
    maxRetries: 5
)
```

This will execute operations a maximum of 6 times with no delay between each execution.

### Using `DelayedRetryPolicy`

`DelayedRetryPolicy` is a retry policy with a static delay before each retry.

Example:

```swift
DefaultRetryPolicy.retryPolicy = DelayedRetryPolicy(
    delay: 100_000_000,
    maxRetries: 5
)
```

This will execute operations a maximum of 6 times with a delay of 100ms between each execution.

### Using `ExponentialBackoffDelayRetryPolicy`

`ExponentialBackoffDelayRetryPolicy` is a retry policy with a exponential increasing delay before each retry.

Example:

```swift
DefaultRetryPolicy.retryPolicy = ExponentialBackoffDelayRetryPolicy(
    minimumBackoffDelay: 100_000_000,
    maximumBackoffDelay: 400_000_000,
    maxRetries: 4
)
```

This will execute operations a maximum of 5 times with the following delays:
- 1th retry: 100ms
- 2nd retry: 200ms
- 3rd retry: 400ms
- 4th retry: 400ms

### Using `NoRetryPolicy`

`NoRetryPolicy` is a retry policy with no retries at all. This can be usefull for unit tests where retries should not be made.

For example, this can be set up in a `XCTestCase`:

```swift
class MyTests: XCTestCase {

    override func setUp() {
        super.setUp()

        DefaultRetryPolicy.retryPolicy = NoRetryPolicy()
    }
}
```
