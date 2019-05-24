//
//  PD4Stat.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/23.
//

import Foundation
@testable import HAMT

struct PD4Stat: CustomStringConvertible {
    var config = PD4BucketConfig(bucketCapInBytes: 4096, slotStrideInBytes: 64)
    var slotStride = 0
    var pairStride = 0

    var emptySlotCount = 0
    var uniqueSlotCount = 0
    var branchSlotCount = 0
    var leafSlotCount = 0

    var hashCollisionCount = 0

    var description: String {
        return "empty/unique/branch/leaf(collision): \(emptySlotCount.metricPrefixed)/\(uniqueSlotCount.metricPrefixed)/\(branchSlotCount.metricPrefixed)/\(leafSlotCount.metricPrefixed)(\(hashCollisionCount))"
    }
}

extension PD4Bucket {
    func collectStat() -> PD4Stat {
        var stat = PD4Stat()
        stat.config = config
        stat.slotStride = MemoryLayout<Slot>.stride
        stat.pairStride = MemoryLayout<Pair>.stride
        iterateAllBranchNodeSlotArrays { (a) in
            for s in a {
                switch s {
                case .none:         stat.emptySlotCount += 1
                case .unique(_):    stat.uniqueSlotCount += 1
                case .branch(_):    stat.branchSlotCount += 1
                case .leaf(let a):
                    stat.leafSlotCount += 1
                    stat.hashCollisionCount += a.count
                }
            }
        }
        return stat
    }
}
