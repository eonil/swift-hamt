//
//  PD4BinaryExponentiation.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/23.
//

///
/// Compressed form of 2^N number in 8 bit.
/// Valid evaluation can result one of these values.
///
///     1...2^256
///
struct PD4BinaryExponentiation {
    var exponent: UInt8
    /// Returns `2 ^ self`.
    var eval: UInt {
        return 0b1 << exponent
    }
}
