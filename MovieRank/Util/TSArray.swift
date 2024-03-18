import Foundation

// Implementation of thread safe array

public class TSArray<Element>: RandomAccessCollection {
    private let queue = DispatchQueue(label: "MovieRankTSArray", attributes: .concurrent)
    private var array: [Element] = []
    public init() {}
    public convenience init(_ initElements: [Element]) {
        self.init()
        array += initElements
    }

    public var startIndex: Int {
        var result: Int = 0
        queue.sync {
            result = array.startIndex

        }
        return result
    }

    public var endIndex: Int {
        var result: Int = 0
        queue.sync {
            result = array.endIndex
        }
        return result
    }

    var first: Element? {
        var result: Element?
        queue.sync {
            result = array.first
        }
        return result
    }
    var last: Element? {
        var result: Element?
        queue.sync {
            result = array.last
        }
        return result
    }
    public var count: Int {
        var result = 0
        queue.sync {
            result = array.count
        }
        return result
    }
    public var isEmpty: Bool {
        var result = true
        queue.sync {
            result = array.isEmpty
        }
        return result
    }
}

extension TSArray {
    public func append(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }

    public func append(_ elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }

    public func insert(_ element: Element, at index: Int) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }

    public func remove(at index: Int, completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            DispatchQueue.main.async { completion?(element) }
        }
    }

    public func removeAll(completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            DispatchQueue.main.async { completion?(elements) }
        }
    }

    public func filter(_ isIncluded: @escaping (Element) -> Bool) -> TSArray {
        var result: TSArray?
        queue.sync { result = TSArray(self.array.filter(isIncluded)) }
        return result!
    }
}

extension TSArray {
    public func index(after i: Int) -> Int {
        var result: Int = 0
        queue.sync {
            result = self.array.index(after: i)
        }
        return result
    }
    public func index(before i: Int) -> Int {
        var result: Int = 0
        queue.sync {
            result = self.array.index(before: i)
        }
        return result
    }

    public func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
}

extension TSArray {
    public subscript(index: Int) -> Element? {
        get {
            var result: Element?

            queue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                result = self.array[index]
            }

            return result

        }
        set {
            guard let newValue = newValue else { return }

            queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
}

extension TSArray {

    public static func += (left: inout TSArray, right: Element) {
        left.append(right)
    }

    public static func += (left: inout TSArray, right: [Element]) {
        left.append(right)
    }
}
