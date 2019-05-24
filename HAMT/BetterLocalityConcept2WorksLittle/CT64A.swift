////
////  CT64A.swift
////  HAMT
////
////  Created by Henry on 2019/05/24.
////
//
//struct CT64A<T>: Sequence where T: DefaultProtocol {
//    typealias Element = T
//    private var bitmap = UInt64(0b0)
//    private var slots = ContiguousArray<T>(repeating: T.default, count: 64)
//    private var flag = false
//
//    mutating func allocSlotSpace() {
//        flag = true
//    }
//    mutating func deallocSlotSpace() {
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
//        return slots.makeIterator()
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
//    }
//}
//extension CT64A: Equatable where T: Equatable {}
//
