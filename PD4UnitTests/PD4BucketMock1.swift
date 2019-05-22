//
//  PD4BucketMock1.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

import XCTest
import GameKit
@testable import SwiftHashTrie

/// Insert-only mock. Inserts sequential keys.
final class PD4BucketMock1 {
    typealias PDB = PD4Bucket<Mock1Key,String>

    private var r = GKMersenneTwisterRandomSource(seed: 0)
    private(set) var source = [Mock1Key:String]()
    private(set) var target = PDB.topLevel256Bytes()
    private(set) var steppingCount = 0
    private(set) var oldVersionTarget: PDB

    init() {
        oldVersionTarget = target
    }

    func runRandom(_ n: Int) {
        for _ in 0..<n {
            stepRandom()
        }
    }
    func stepRandom() {
        oldVersionTarget = target
        insertRandom()
        steppingCount += 1
    }
    private func insertRandom() {
        let k = Mock1Key(num: steppingCount)
        let v = ">"
        source[k] = v
        target.set(k, v)
        XCTAssertEqual(source.count, target.count)
        XCTAssertEqual(target.get(k), v)
    }
}

struct Mock1Key: Hashable, PD4Hashable {
    private(set) var num: Int
    var hashBits: Int {
        return num.hashValue
    }
}

