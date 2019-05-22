//
//  PD4Config.swift
//  PD4
//
//  Created by Henry on 2019/05/22.
//  Copyright © 2019 Eonil. All rights reserved.
//

///
///
///
struct PD4BucketConfig {
    /// A bucket size is 64KiB at maximum.
    let bucketCapInBytes: UInt16

    /// Single element can be sized up to 64KiB at maximum.
    let slotCapInBucket: UInt16
    let bitMaskForSlotCapFromLSB: UInt16

    /// Hash bit count used for each level.
    /// This value is cached to gain a little performance gain.
    let bitCountPerLevel: UInt8
    private(set) var currentLevel: UInt8

    init(bucketCapInBytes z: UInt16, slotStrideInBytes: UInt16) {
        assert(z > 0)
        assert(slotStrideInBytes > 0)
        bucketCapInBytes = z
        slotCapInBucket = bucketCapInBytes / slotStrideInBytes
        bitCountPerLevel = findBitsForSlotCap(slotCap: slotCapInBucket)

        let a = UInt16(0b0)
        let b = ~a
        let c = b << bitCountPerLevel
        let d = ~c
        bitMaskForSlotCapFromLSB = d
        currentLevel = 0
    }
    func maxLevel() -> Int {
        let max_bits = MemoryLayout<Int>.size * 8
        return max_bits / Int(bitCountPerLevel)
    }
    var isFinalBranch: Bool {
        return currentLevel + 1 == maxLevel()
    }
    func nextLevel() -> PD4BucketConfig {
        var x = self
        x.currentLevel += 1
        return x
    }
}

private extension UInt8 {
    /// Returns `2 ^ self`.
    func binaryExponentiation() -> Int {
        return 0b1 << self
    }
}

private func findBitsForSlotCap(slotCap: UInt16) -> UInt8 {
    let z = MemoryLayout<Int>.size * 8 // machine word size.
    for i in 0..<z {
        let n = ~((~UInt(0)) << i)
        if slotCap <= n { return UInt8(i) }
    }
    // at this point, assumes maximum machine word size
    // as 2^8 = 256 bit. Any information after 256 bits
    // will be ignored on machine with bigger word size.
    return UInt8(z)
}
