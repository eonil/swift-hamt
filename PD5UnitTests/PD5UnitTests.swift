//
//  PD5UnitTests.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/22.
//

import XCTest
import GameKit
@testable import HAMT

final class PD5TestCase: XCTestCase {
    func test1InsertOneWithCorrectBucketStructure() {
        typealias K = PD5MocklessTestKey
        typealias SD = [K:Int]
        typealias PDB = PD5Bucket64<K,Int>
        var b = PDB()
        b[K(111)] = 222
        XCTAssertEqual(K(111).hashBits, 111)
        let ik = b.slotIndex(for: 111)
        XCTAssertEqual(b.slots.count, 1)
        XCTAssertEqual(b.slots.capacity, 64)
        XCTAssertEqual(b.slots.get(index: ik, default: .none), .unique(PDB.Pair(K(111),222)))
        for i in 0..<64 {
            if ik != i {
                XCTAssertEqual(b.slots.get(index: UInt(i), default: .none), .none)
            }
        }
    }

    func test2InsertRemoveWithCorrectBucketStructure() {
        typealias K = PD5MocklessTestKey
        typealias SD = [K:Int]
        typealias PDB = PD5Bucket64<K,Int>
        var d = SD()
        var b = PDB()
        for i in 0..<64 {
            let k = K(i)
            let v = i
            b[k] = v
            d[k] = v
            XCTAssertEqual(b.count, d.count)
            XCTAssertEqual(d[k], v)
            XCTAssertEqual(b[k], v)
        }
        do {
            let k = K(64)
            let v = 64
            b[k] = v
            d[k] = v
            XCTAssertEqual(b.count, d.count)
            XCTAssertEqual(d[k], v)
            XCTAssertEqual(b[k], v)
            switch b.slots.get(index: 0, default: .none) {
            case .branch(let b1):
                XCTAssertEqual(b1.slots.count, 2)
                XCTAssertEqual(b1.slots.get(index: 0, default: .none), .unique(PDB.Pair(K(0),0)))
                XCTAssertEqual(b1.slots.get(index: 1, default: .none), .unique(PDB.Pair(K(64),64)))
            default:
                XCTFail()
            }
        }
        do {
            let k = K(0)
            b[k] = nil
            d[k] = nil
            XCTAssertEqual(b.count, d.count)
            XCTAssertEqual(d[k], nil)
            XCTAssertEqual(b[k], nil)
            XCTAssertEqual(b.slots.get(index: 0, default: .none), .unique(PDB.Pair(K(64),64)))
        }
    }

    func test3InsertUpdateRemove() {
        typealias K = PD5MocklessTestKey
        typealias SD = [K:Int]
        typealias PDB = PD5Bucket64<K,Int>
        let r = GKMersenneTwisterRandomSource(seed: 0)
        var d = SD()
        var b = PDB()
        for i in 0..<10_000 {
            let k = K(i)
            let v = i
            b[k] = v
            d[k] = v
            XCTAssertEqual(b.count, d.count)
            XCTAssertEqual(d[k], v)
            XCTAssertEqual(b[k], v)
        }
        for i in 0..<10_000 {
            let k = K(r.nextInt(upperBound: 10_000))
            b[k] = i
            d[k] = i
            XCTAssertEqual(b.count, d.count)
            XCTAssertEqual(d[k], i)
            XCTAssertEqual(b[k], i)
        }
        for i in 0..<10_000 {
            let k = K(i)
            b[k] = nil
            d[k] = nil
            XCTAssertEqual(b.count, d.count)
            XCTAssertEqual(d[k], nil)
            XCTAssertEqual(b[k], nil)
        }
    }
    func test4HAMTCounting() {
        
    }
}

private struct PD5MocklessTestKey: PD5Hashable, Hashable {
    var num: Int
    init(_ n: Int) {
        num = n
    }
    var hashBits: UInt {
        return UInt(bitPattern: num)
    }
    func hash(into h: inout Hasher) {
        h.combine(num)
    }
}

private func == <K,V>(_ a: HAMT<K,V>, _ b: [K:V]) -> Bool where K: Hashable, V: Equatable {
    for k in a.keys {
        guard b[k] == a[k] else { return false }
    }
    for k in b.keys {
        guard a[k] == b[k] else { return false }
    }
    return true
}
