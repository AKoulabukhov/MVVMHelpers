import Foundation

public struct Observable<Value> {
    private let observations = NSHashTable<Observation>.weakObjects()
    private var _value: Value

    public var value: Value {
        get { return self._value }
        set {
            let oldValue = self._value
            self._value = newValue
            self.handleValueChanged(from: oldValue, to: newValue)
        }
    }

    public init(_ value: Value) {
        self._value = value
    }

    public mutating func silentSet(_ newValue: Value) {
        self._value = newValue
    }

    public func observe(_ handler: @escaping ChangeHandler<Value>) -> ObservationProtocol {
        let observation = Observation(handler)
        self.observations.add(observation)
        return observation
    }

    public func observeFromCurrent(_ handler: @escaping ChangeHandler<Value>) -> ObservationProtocol {
        handler(self.value, self.value)
        return self.observe(handler)
    }

    public func observe(_ handler: @escaping ValueHandler<Value>) -> ObservationProtocol {
        let changeHandler: ChangeHandler<Value> = { _, newValue in handler(newValue) }
        return self.observe(changeHandler)
    }

    public func observeFromCurrent(_ handler: @escaping ValueHandler<Value>) -> ObservationProtocol {
        handler(self.value)
        return self.observe(handler)
    }

    private func handleValueChanged(from oldValue: Value, to newValue: Value) {
        self.observations.allObjects.forEach {
            $0.handleValueChanged(from: oldValue, to: newValue)
        }
    }
}

private extension Observable {
    final class Observation: ObservationProtocol {
        private let handler: ChangeHandler<Value>
        private(set) var isValid: Bool = true

        init(_ handler: @escaping ChangeHandler<Value>) {
            self.handler = handler
        }

        func handleValueChanged(from oldValue: Value, to newValue: Value) {
            guard self.isValid else { return }
            self.handler(oldValue, newValue)
        }

        func invalidate() {
            self.isValid = false
        }
    }
}

extension Observable where Value: Equatable {

    public func observeNew(_ handler: @escaping ChangeHandler<Value>) -> ObservationProtocol {
        let filteringHandler: ChangeHandler<Value> = { oldValue, newValue in
            guard oldValue != newValue else { return }
            handler(oldValue, newValue)
        }
        return self.observe(filteringHandler)
    }

    public func observeNewFromCurrent(_ handler: @escaping ChangeHandler<Value>) -> ObservationProtocol {
        handler(self.value, self.value)
        return self.observeNew(handler)
    }

    public func observeNew(_ handler: @escaping ValueHandler<Value>) -> ObservationProtocol {
        let filteringHandler: ChangeHandler<Value> = { oldValue, newValue in
            guard oldValue != newValue else { return }
            handler(newValue)
        }
        return self.observe(filteringHandler)
    }

    public func observeNewFromCurrent(_ handler: @escaping ValueHandler<Value>) -> ObservationProtocol {
        handler(self.value)
        return self.observeNew(handler)
    }

}

// MARK: - Helpers

extension Observable: ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringLiteral where Value == String {
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Observable: ExpressibleByIntegerLiteral where Value == Int {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Observable: ExpressibleByFloatLiteral where Value == Double {
    public init(floatLiteral: Double) {
        self.init(floatLiteral)
    }
}

extension Observable: ExpressibleByBooleanLiteral where Value == Bool {
    public init(booleanLiteral: Bool) {
        self.init(booleanLiteral)
    }
}
