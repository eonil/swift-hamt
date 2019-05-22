////
////  ValuePool.swift
////  SwiftHashTrie-macOS
////
////  Created by Henry on 2019/05/24.
////
//
//import Foundation
//
//final class MultiTypeValuePool {
//    static let shared = MultiTypeValuePool()
//    
//    private var map = [ObjectIdentifier: AnyObject]()
//    subscript<T>(_ :T.Type) -> ValuePool<T> {
//        get {
//            return (map[ObjectIdentifier(T.self)] as! ValuePool<T>?)
//                ?? ValuePool<T>(elementCountInUnit: 64, unitCount: 1024*1024)
//        }
//    }
//}
//final class ValuePool<T> where T: DefaultProtocol {
//    private let elementCountInUnit: Int
//    private let unitCount: Int
//    private var arr: ContiguousArray<T>
//    private var freeIndices = IndexSet()
//    private let lock = NSLock()
//    init(elementCountInUnit z: Int, unitCount c: Int) {
//        elementCountInUnit = z
//        unitCount = c
//        arr = ContiguousArray<T>(repeating: .default, count: z*c)
//        freeIndices.insert(integersIn: 0..<c)
//    }
//    deinit {
//    }
//    var isEmpty: Bool {
//        return freeIndices.count == unitCount
//    }
//    func alloc() -> ArraySlice<T> {
//        lock.lock()
//        let i = freeIndices.first
//        lock.unlock()
//        guard let i1 = i else { fatalError("No more space.") }
//        let start = i1 * elementCountInUnit
//        let end = start + elementCountInUnit
//        let slice = arr[start..<end]
//        return slice
//    }
//    func dealloc(_ s: ArraySlice<T>) {
//        let i = s.startIndex / elementCountInUnit
//        lock.lock()
//        freeIndices.insert(i)
//        lock.unlock()
//    }
//}
