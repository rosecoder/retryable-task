import XCTest
@testable import RetryableTask
import Logging
import SwiftLogTesting

private var testCancellationCallCounter = 0

final class withRetryableTaskTests: XCTestCase {

    private let loggingMessage = "warning TestError()|withRetryableTask.swift|doTry()"

    override func setUp() {
        super.setUp()

        TestLogMessages.bootstrap()
    }

    private struct TestError: Error {}

    // MARK: -

    func testWithSuccessResult() async throws {
        let logger = Logger(label: "xctest:\(#function)")
        let logContainer = TestLogMessages.container(forLabel: logger.label)

        var callCounter = 0

        try await withRetryableTask(
            policy: ImmediateRetryPolicy(maxRetries: 1),
            logger: logger
        ) {
            callCounter += 1
        }

        XCTAssertTrue(logContainer.messages.isEmpty)
        XCTAssertEqual(callCounter, 1)
    }

    func testWithThrowingResult() async throws {
        let logger = Logger(label: "xctest:\(#function)")
        let logContainer = TestLogMessages.container(forLabel: logger.label)

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

            XCTAssertEqual(logContainer.messages.count, 2)
            XCTAssertEqual(logContainer.messages[0].toString(), loggingMessage)
            XCTAssertEqual(logContainer.messages[1].toString(), loggingMessage)
        }
    }

    func testWithSuccessResultAfterSingleRetry() async throws {
        let logger = Logger(label: "xctest:\(#function)")
        let logContainer = TestLogMessages.container(forLabel: logger.label)

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

        XCTAssertEqual(logContainer.messages.count, 1)
        XCTAssertEqual(logContainer.messages[0].toString(), loggingMessage)
        XCTAssertEqual(callCounter, 2)
    }

    func testCancellation() async throws {
        let task = Task.detached {
            try await withRetryableTask(
                policy: DelayedRetryPolicy(delay: 100_000_000, maxRetries: 100)
            ) {
                testCancellationCallCounter += 1
                throw TestError()
            }
        }

        try await Task.sleep(nanoseconds: 1_000_000_000)

        XCTAssertFalse(task.isCancelled)
        task.cancel()
        XCTAssertTrue(task.isCancelled)

        do {
            try await task.value
        } catch {
            if !(error is CancellationError) {
                throw error
            }
        }

        XCTAssertEqual(testCancellationCallCounter, 10, accuracy: 1)
    }
}
