import Foundation

// Implementation of thread safe array

public class TSArray<Element>{
    private let queue = DispatchQueue(label: "MovieRankTSArray", attributes: .concurrent);
    private var array: [Element] = []
    public init(){}
    public convenience init(_ initElements: [Element]){
        self.init()
        array += initElements
    }
    var first: Element? {
        var result: Element?
        queue.sync {
            result = array.first;
        }
        return result;
    }
    var last: Element? {
        var result: Element?
        queue.sync {
            result = array.last;
        }
        return result;
    }
    var count: Int {
        var result = 0
        queue.sync {
            result = array.count;
        }
        return result;
    }
    var isEmpty: Bool {
        var result = true
        queue.sync {
            result = array.isEmpty;
        }
        return result;
    }
}

public extension TSArray{
    func append(_ element: Element){
        queue.async (flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func append(_ elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    func insert(_ element: Element, at index: Int){
        queue.async (flags: .barrier){
            self.array.insert(element, at: index)
        }
    }
    
    func remove(at index: Int, completion: ((Element)->Void)? = nil){
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    func removeAll(completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            DispatchQueue.main.async { completion?(elements) }
        }
    }
    
    func arrayCopy() -> [Element]{
        return array;
    }
}

public extension TSArray {
    func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
}


public extension TSArray {
    subscript(index: Int) -> Element? {
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

public extension TSArray{
    
    static func +=(left: inout TSArray, right: Element) {
        left.append(right)
    }
    
    static func +=(left: inout TSArray, right: [Element]) {
        left.append(right)
    }
}
