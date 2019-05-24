////
////  CT64B.swift
////  HAMT
////
////  Created by Henry on 2019/05/24.
////
//
//import Foundation
//
//struct CT64B<T>: Sequence where T: DefaultProtocol {
//    typealias Element = T
//    private var bitmap = UInt64(0b0)
//    private var slots = ArraySlice<T>.init()
//    private var flag = false
//
//    mutating func allocSlotSpace() {
//        flag = true
//        slots = MultiTypeValuePool.shared[T.self].alloc()
////        let uz = MemoryLayout<T>.stride * 64
////        slots = MultiSizeMemoryPool.shared[forUnitStrideInBytes: uz].alloc().bindMemory(to: T.self, capacity: 64)
////        slots = Pool.shared.alloc()
//    }
//    mutating func deallocSlotSpace() {
////        let uz = MemoryLayout<T>.stride * 64
////        MultiSizeMemoryPool.shared[forUnitStrideInBytes: uz].dealloc(slots)
//        MultiTypeValuePool.shared[T.self].dealloc(slots)
//        slots = ArraySlice<T>.init()
//        flag = false
//    }
//
//    @inlinable
//    @inline(__always)
//    var capacity: Int {
//        return 64
//    }
//    @inlinable
//    @inline(__always)
//    var count: Int {
//        precondition(flag)
//        return bitmap.nonzeroBitCount
//    }
//    @inlinable
//    @inline(__always)
//    func makeIterator() -> ContiguousArray<T>.Iterator {
//        precondition(flag)
//        var a = ContiguousArray<T>()
//        for i in 0..<64 {
//            if let v = get1(index: UInt(i)) {
//                a.append(v)
//            }
//        }
//        return a.makeIterator()
//    }
//
//    @inlinable
//    @inline(__always)
//    func get(index k: UInt, default defv: @autoclosure() -> T) -> T {
//        precondition(flag)
//        assert(k < 64)
//        assert(0 <= k)
//        let mask = UInt64(0b1) << k
//        if (bitmap & mask).nonzeroBitCount == 0 {
//            // No value at index.
//            return defv()
//        }
//        else {
//            let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
//            let bitCount = (bitmap & countingMask).nonzeroBitCount
//            return slots[bitCount]
//        }
//    }
//    @inlinable
//    @inline(__always)
//    func get1(index k: UInt) -> T? {
//        precondition(flag)
//        assert(k < 64)
//        assert(0 <= k)
//        let mask = UInt64(0b1) << k
//        if (bitmap & mask).nonzeroBitCount == 0 {
//            // No value at index.
//            return nil
//        }
//        else {
//            let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
//            let bitCount = (bitmap & countingMask).nonzeroBitCount
//            return slots[bitCount]
//        }
//    }
//
//    @inlinable
//    @inline(__always)
//    mutating func set(index k: UInt, _ v: T) {
//        precondition(flag)
//        assert(k < 64)
//        assert(0 <= k)
//        let mask = UInt64(0b1) << k
//        let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
//        let bitCount = (bitmap & countingMask).nonzeroBitCount
//        bitmap |= mask
//        slots[bitCount] = v
//    }
//    @inlinable
//    @inline(__always)
//    mutating func unset(index k: UInt) {
//        precondition(flag)
//        assert(k < 64)
//        assert(0 <= k)
//        let mask = UInt64(0b1) << k
//        let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
//        let bitCount = (bitmap & countingMask).nonzeroBitCount
//        slots[bitCount] = T.default
//        bitmap &= ~mask
//
//        if count == 8 {
//
//        }
//    }
//}
//extension CT64B: Equatable where T: Equatable {}
//
//final class Pool {
//    static let shared = Pool()
//
//    private var ptr = UnsafeMutableRawPointer.allocate(byteCount: 1024*1024*1024, alignment: 0)
//    private var consumedBytes = 0
//    deinit {
//        ptr.deallocate()
//    }
//    func first<T>() -> UnsafeMutablePointer<T> {
//        let x = MemoryLayout<T>.stride
//        let n = 1024*1024*1024 / x
//        let ptr1 = ptr.bindMemory(to: T.self, capacity: n)
//        return ptr1
//    }
//    func alloc<T>() -> UnsafeMutablePointer<T> {
//        let x = MemoryLayout<T>.stride
//        let n = 1024*1024*1024 / x
//        let ptr1 = ptr.bindMemory(to: T.self, capacity: n)
//        let ptr2 = ptr1 + consumedBytes / x
//        consumedBytes += x * 64
//        return ptr2
//    }
//    func dealloc<T>(_ a: UnsafeMutablePointer<T>) {
//
//    }
//}
//
//final class MultiSizeMemoryPool {
//    static let dummy = UnsafeMutableRawPointer.allocate(byteCount: 128, alignment: 0)
//    static let shared = MultiSizeMemoryPool()
//    private var map = [Int: UnitMemoryPool]()
//    subscript(forUnitStrideInBytes uz: Int) -> UnitMemoryPool {
//        get {
//            return map[uz, default: UnitMemoryPool(unitStrideInBytes: uz, unitCount: 1024*1024)]
//        }
//        set(v) {
//            map[uz] = v.isEmpty ? nil : v
//        }
//    }
//}
//
//final class UnitMemoryPool {
//    private let unitStrideInBytes: Int
//    private let unitCount: Int
//    private let ptr: UnsafeMutableRawPointer
//    private var freeIndices = IndexSet()
//    private let lock = NSLock()
//    init(unitStrideInBytes z: Int, unitCount c: Int) {
//        unitStrideInBytes = z
//        unitCount = c
//        ptr = UnsafeMutableRawPointer.allocate(byteCount: z*c, alignment: z)
//        freeIndices.insert(integersIn: 0..<c)
//    }
//    deinit {
//        ptr.deallocate()
//    }
//    var isEmpty: Bool {
//        return freeIndices.count == unitCount
//    }
//    func alloc() -> UnsafeMutableRawPointer {
//        lock.lock()
//        defer { lock.unlock() }
//        guard let i = freeIndices.first else { fatalError("No more space.") }
//        let offset = i * unitStrideInBytes
//        let ptr1 = ptr.advanced(by: offset)
//        return ptr1
//    }
//    func dealloc(_ ptr1: UnsafeMutableRawPointer) {
//        let dt = ptr1 - ptr
//        let i = dt / unitStrideInBytes
//        lock.lock()
//        freeIndices.insert(i)
//        lock.unlock()
//    }
//}
