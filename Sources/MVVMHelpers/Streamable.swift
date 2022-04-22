import Foundation

public struct Streamable<Value> {
    private let observations = NSHashTable<Observation>.weakObjects()

    public init() { }

    public func emit(_ value: Value) {
        self.observations.allObjects.forEach {
            $0.handleEmission(value)
        }
    }

    public func observe(_ handler: @escaping ValueHandler<Value>) -> ObservationProtocol {
        let observation = Observation(handler)
        self.observations.add(observation)
        return observation
    }
}

private extension Streamable {
    final class Observation: ObservationProtocol {
        private let handler: ValueHandler<Value>
        private(set) var isValid: Bool = true

        init(_ handler: @escaping ValueHandler<Value>) {
            self.handler = handler
        }

        func handleEmission(_ value: Value) {
            guard self.isValid else { return }
            self.handler(value)
        }

        func invalidate() {
            self.isValid = false
        }
    }
}
