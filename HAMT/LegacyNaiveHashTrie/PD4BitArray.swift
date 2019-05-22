//
//  PD4BitArray.swift
//  PD4
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

struct PD4BitArray<N>: Equatable where N: BinaryInteger {
    let bits: N
    init(_ bits: N) {
        self.bits = bits
    }
    /// Captures bits in the range and move it to
    /// LSB side and return.
    func capture(_ r: Range<Int>) -> PD4BitArray {
        let bc = MemoryLayout<N>.size * 8
        let a = bits << r.lowerBound
        let b = a >> (bc - r.count)
        return PD4BitArray(b)
    }
    @inline(__always)
    func capture(offset: Int, length: Int) -> PD4BitArray {
        let bc = MemoryLayout<N>.size * 8
        let a = bits << offset
        let b = a >> (bc - length)
        return PD4BitArray(b)
    }
}

