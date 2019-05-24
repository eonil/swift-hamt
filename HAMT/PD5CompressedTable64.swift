//
//  PD5CompressedArray64.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/23.
//

struct PD5CompressedTable64<T>: Sequence {
    typealias Element = T
    private var bitmap = UInt64(0b0)
    private var slots = ContiguousArray<T>()

    @inlinable
    var capacity: Int {
        return 64
    }
    @inlinable
    var count: Int {
        return bitmap.nonzeroBitCount
    }
    @inlinable
    func makeIterator() -> ContiguousArray<T>.Iterator {
        return slots.makeIterator()
    }

    @inlinable
    func get(index k: UInt, default defv: @autoclosure() -> T) -> T {
        assert(k < 64)
        assert(0 <= k)
        let mask = UInt64(0b1) << k
        if (bitmap & mask).nonzeroBitCount == 0 {
            // No value at index.
            return defv()
        }
        else {
            let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
            let bitCount = (bitmap & countingMask).nonzeroBitCount
            return slots[bitCount]
        }
    }
    @inlinable
    func get1(index k: UInt) -> T? {
        assert(k < 64)
        assert(0 <= k)
        let mask = UInt64(0b1) << k
        if (bitmap & mask).nonzeroBitCount == 0 {
            // No value at index.
            return nil
        }
        else {
            let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
            let bitCount = (bitmap & countingMask).nonzeroBitCount
            return slots[bitCount]
        }
    }

    @inlinable
    mutating func set(index k: UInt, _ v: T) {
        assert(k < 64)
        assert(0 <= k)
        let mask = UInt64(0b1) << k
        let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
        let bitCount = (bitmap & countingMask).nonzeroBitCount
        if (bitmap & mask).nonzeroBitCount == 0 {
            // No value at index.
            bitmap |= mask
            slots.insert(v, at: bitCount)
        }
        else {
            slots[bitCount] = v
        }
    }
    @inlinable
    mutating func unset(index k: UInt) {
        assert(k < 64)
        assert(0 <= k)
        let mask = UInt64(0b1) << k
        let countingMask = ~(UInt64(0xffff_ffff_ffff_ffff) << k)
        let bitCount = (bitmap & countingMask).nonzeroBitCount
        if (bitmap & mask).nonzeroBitCount == 0 {
            // No value at index.
            // Nothing to do.
        }
        else {
            slots.remove(at: bitCount)
            bitmap &= ~mask
        }
    }
}

/// Two tables are equal if all elements at same positions are equal.
extension PD5CompressedTable64: Equatable where T: Equatable {}
