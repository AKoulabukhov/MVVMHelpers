import XCTest
@testable import MVVMHelpers

final class StreamableTests: XCTestCase {

    private var streamable: Streamable<String>!
    private var observation: ObservationProtocol!
    private var values: [String]!

    override func setUp() {
        super.setUp()
        streamable = .init()
        values = []
    }

    override func tearDown() {
        observation = nil
        super.tearDown()
    }

    func testThat_WhenValueChanged_ThenValueObserverNotified() {
        let value = "value"
        observation = streamable.observe { newValue in
            self.values.append(newValue)
        }

        streamable.emit(value)

        XCTAssertEqual(values, [value])
    }

    func testThat_WhenObservationInvalidated_ThenValueObserverNotNotified() {
        let value = "value"
        observation = streamable.observe { newValue in
            self.values.append(newValue)
        }

        observation.invalidate()
        streamable.emit(value)

        XCTAssertEqual(values, [])
    }

    func testThat_WhenObservationDeallocated_ThenValueObserverNotNotified() {
        let value = "value"
        observation = streamable.observe { newValue in
            self.values.append(newValue)
        }

        observation = nil
        streamable.emit(value)

        XCTAssertEqual(values, [])
    }
}
