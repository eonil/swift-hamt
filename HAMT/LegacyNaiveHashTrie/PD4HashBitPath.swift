//
//  HashPath.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/22.
//

import Foundation

extension PD4Hashable {
    func pathify() -> PD4HashBitPath {
        return PD4HashBitPath(UInt(bitPattern: hashBits))
    }
}
struct PD4HashBitPath {
    private let bits: UInt
    init(_ n: UInt) {
        bits = n
    }
    func index(config x: PD4BucketConfig) -> Int {
        let m = UInt(x.bitMaskForSlotCapFromLSB)
        let n = bits & m % UInt(x.slotCapInBucket)
        return Int(n)
    }
    func nextLevel(config x: PD4BucketConfig) -> PD4HashBitPath {
        let bits1 = bits >> x.bitCountPerLevel
        return PD4HashBitPath(bits1)
    }
    func nextLevel(config x: PD4BucketConfig, times n: UInt8) -> PD4HashBitPath {
        let bits1 = bits >> (UInt(x.bitCountPerLevel) * UInt(n))
        return PD4HashBitPath(bits1)
    }
}
