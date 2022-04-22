import XCTest
@testable import MVVMHelpers

final class ObservableTests: XCTestCase {

    private let initialValue = "initial_value"
    private var observable: Observable<String>!
    private var observation: ObservationProtocol!
    private var changes: [Change<String>]!
    private var values: [String]!

    override func setUp() {
        super.setUp()
        observable = .init(initialValue)
        changes = []
        values = []
    }

    override func tearDown() {
        observation = nil
        super.tearDown()
    }

    func testThat_WhenObservableCreated_ThenInitialValueSet() {
        XCTAssertEqual(observable.value, initialValue)
    }

    func testThat_WhenValueChanged_ThenChangeObserverNotified() {
        let newValue = "new_value"
        observation = observable.observe { oldValue, newValue in
            self.changes.append(Change(from: oldValue, to: newValue))
        }

        observable.value = newValue

        XCTAssertEqual(changes, [Change(from: initialValue, to: newValue)])
    }

    func testThat_WhenValueChanged_ThenValueObserverNotified() {
        let newValue = "new_value"
        observation = observable.observe { newValue in
            self.values.append(newValue)
        }

        observable.value = newValue

        XCTAssertEqual(values, [newValue])
    }

    func testThat_GivenObservingFromInitialValue_WhenValueChanged_ThenChangeObserverNotified() {
        let newValue = "new_value"
        observation = observable.observeFromCurrent { oldValue, newValue in
            self.changes.append(Change(from: oldValue, to: newValue))
        }

        observable.value = newValue

        XCTAssertEqual(changes, [
            Change(from: initialValue, to: initialValue),
            Change(from: initialValue, to: newValue)
        ])
    }

    func testThat_GivenObservingFromInitialValue_WhenValueChanged_ThenValueObserverNotified() {
        let newValue = "new_value"
        observation = observable.observeFromCurrent { newValue in
            self.values.append(newValue)
        }

        observable.value = newValue

        XCTAssertEqual(values, [initialValue, newValue])
    }

    func testThat_WhenObservationInvalidated_ThenValueObserverNotNotified() {
        let newValue = "new_value"
        observation = observable.observe { newValue in
            self.values.append(newValue)
        }

        observation.invalidate()
        observable.value = newValue

        XCTAssertEqual(values, [])
    }

    func testThat_WhenObservationDeallocated_ThenValueObserverNotNotified() {
        let newValue = "new_value"
        observation = observable.observe { newValue in
            self.values.append(newValue)
        }

        observation = nil
        observable.value = newValue

        XCTAssertEqual(values, [])
    }

    func testThat_GivenObservingNew_WhenValueChanged_ThenChangeObserverNotified() {
        let newValue1 = initialValue
        let newValue2 = "new_value"
        observation = observable.observeNew { oldValue, newValue in
            self.changes.append(Change(from: oldValue, to: newValue))
        }

        observable.value = newValue1
        observable.value = newValue2

        XCTAssertEqual(changes, [Change(from: initialValue, to: newValue2)])
    }

    func testThat_GivenObservingNew_WhenValueChanged_ThenValueObserverNotified() {
        let newValue1 = initialValue
        let newValue2 = "new_value"
        observation = observable.observeNew { newValue in
            self.values.append(newValue)
        }

        observable.value = newValue1
        observable.value = newValue2

        XCTAssertEqual(values, [newValue2])
    }

    func testThat_GivenObservingNewFromInitialValue_WhenValueChanged_ThenChangeObserverNotified() {
        let newValue1 = initialValue
        let newValue2 = "new_value"
        observation = observable.observeNewFromCurrent { oldValue, newValue in
            self.changes.append(Change(from: oldValue, to: newValue))
        }

        observable.value = newValue1
        observable.value = newValue2

        XCTAssertEqual(changes, [
            Change(from: initialValue, to: initialValue),
            Change(from: initialValue, to: newValue2)
        ])
    }

    func testThat_GivenObservingNewFromInitialValue_WhenValueChanged_ThenValueObserverNotified() {
        let newValue1 = initialValue
        let newValue2 = "new_value"
        observation = observable.observeNewFromCurrent { newValue in
            self.values.append(newValue)
        }

        observable.value = newValue1
        observable.value = newValue2

        XCTAssertEqual(values, [initialValue, newValue2])
    }
}

private extension ObservableTests {
    struct Change<Value: Equatable>: Equatable {
        let from: Value
        let to: Value
    }
}
