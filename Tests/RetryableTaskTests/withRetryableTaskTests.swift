import Testing
@testable import RetryableTask
import Logging
import SwiftLogTesting

@Suite struct withRetryableTaskTests {

    init() {
        TestLogMessages.bootstrap()
    }

    private struct TestError: Error {}

    // MARK: -

    @Test func withSuccessResult() async throws {
        let logger = Logger(label: "testing:\(#function)")
        let logContainer = TestLogMessages.container(forLabel: logger.label)

        var callCounter = 0

        try await withRetryableTask(
            policy: ImmediateRetryPolicy(maxRetries: 1),
            logger: logger
        ) {
            callCounter += 1
        }

        #expect(logContainer.messages.isEmpty)
        #expect(callCounter == 1)
    }

    @Test func withThrowingResult() async throws {
        let logger = Logger(label: "testing:\(#function)")
        let logContainer = TestLogMessages.container(forLabel: logger.label)
        let expectedLoggingMessage = "warning TestError()|withRetryableTaskTests.swift|withThrowingResult()"

        do {
            try await withRetryableTask(
                policy: ImmediateRetryPolicy(maxRetries: 2),
                logger: logger
            ) {
                throw TestError()
            }
        } catch {
            guard error is TestError else {
                throw error
            }

            #expect(logContainer.messages.count == 2)
            #expect(logContainer.messages[0].toString() == expectedLoggingMessage)
            #expect(logContainer.messages[1].toString() == expectedLoggingMessage)
        }
    }

    @Test func withSuccessResultAfterSingleRetry() async throws {
        let logger = Logger(label: "testing:\(#function)")
        let logContainer = TestLogMessages.container(forLabel: logger.label)
        let expectedLoggingMessage = "warning TestError()|withRetryableTaskTests.swift|withSuccessResultAfterSingleRetry()"

        var callCounter = 0

        try await withRetryableTask(
            policy: ImmediateRetryPolicy(maxRetries: 1),
            logger: logger
        ) {
            callCounter += 1
            if callCounter == 1 {
                throw TestError()
            }
        }

        #expect(logContainer.messages.count == 1)
        #expect(logContainer.messages[0].toString() == expectedLoggingMessage)
        #expect(callCounter == 2)
    }

    @Test func cancellation() async throws {

        nonisolated(unsafe) var testCancellationCallCounter = 0

        let task = Task.detached {
            try await withRetryableTask(
                policy: DelayedRetryPolicy(delay: 100_000_000, maxRetries: 100)
            ) {
                testCancellationCallCounter += 1
                throw TestError()
            }
        }

        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(!task.isCancelled)
        task.cancel()
        #expect(task.isCancelled)

        do {
            try await task.value
        } catch {
            if !(error is CancellationError) {
                throw error
            }
        }

        #expect(abs(testCancellationCallCounter - 10) <= 1)
    }
}
