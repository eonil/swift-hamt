//
//  PD4Bucket.preset.swift
//  PD4
//
//  Created by Henry on 2019/05/22.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

//
// 2^14 = 16384
// 2^12 = 4096
// 2^10 = 1024
// 2^8 = 256
// 2^6 = 64
//

extension PD4Bucket {
    static func topLevel16384Bytes() -> PD4Bucket {
        let x = Config(
            bucketCapInBytes: 0b1 << 14,
            slotStrideInBytes: UInt16(MemoryLayout<Slot>.stride))
        return PD4Bucket(config: x)
    }
    static func topLevel4096Bytes() -> PD4Bucket {
        let x = Config(
            bucketCapInBytes: 0b1 << 12,
            slotStrideInBytes: UInt16(MemoryLayout<Slot>.stride))
        return PD4Bucket(config: x)
    }
    static func topLevel1024Bytes() -> PD4Bucket {
        let x = Config(
            bucketCapInBytes: 0b1 << 10,
            slotStrideInBytes: UInt16(MemoryLayout<Slot>.stride))
        return PD4Bucket(config: x)
    }
    static func topLevel256Bytes() -> PD4Bucket {
        let x = Config(
            bucketCapInBytes: 0b1 << 8,
            slotStrideInBytes: UInt16(MemoryLayout<Slot>.stride))
        return PD4Bucket(config: x)
    }
    static func topLevel64Bytes() -> PD4Bucket {
        let x = Config(
            bucketCapInBytes: 0b1 << 6,
            slotStrideInBytes: UInt16(MemoryLayout<Slot>.stride))
        return PD4Bucket(config: x)
    }
}

private func findBitsForSlotCap(slotCap: Int) -> UInt8 {
    let z = MemoryLayout<Int>.size * 8 // machine word size.
    for i in 0..<z {
        let n = ~((~UInt(0)) << i)
        if slotCap <= n { return UInt8(i) }
    }
    // at this point, assumes maximum machine word size
    // as 2^8 = 256 bit. Any information after 256 bits
    // will be ignored on machine with bigger word size.
    return UInt8(MemoryLayout<Int>.size)
}
