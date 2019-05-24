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
        // This test is too slow without optimization...
        // Uses irreproducible random, therefore this test
        // is not reproducible.
        let c = 1_00_000
        var h = HAMT<Int,Int>()
        var d = [Int:Int]()
        let ns = Array(0..<c).shuffled()
        var ks = Set<Int>(0..<c)
        for i in 0..<c {
            XCTAssertEqual(h.count, i)
            h[i] = i
            d[i] = i
            XCTAssertEqual(h[i], i)
            if i % 1_000 == 0 {
                print("\(i)/\(c) inserted.")
            }
        }
        XCTAssertEqual(h.count, c)

        let r = GKMersenneTwisterRandomSource(seed: 0)
        var ec = c
        var insertc = 0
        var updatec = 0
        var removec = 0
        for n in 0..<c {
            switch abs(r.nextInt()) % 3 {
            case 0:
                let k = ns[n]
                if h[k] == nil {
                    h[k] = k
                    d[k] = k
                    ec += 1
                    XCTAssertEqual(h[k], k)
                    XCTAssertEqual(h.count, ec)
                    XCTAssertTrue(h == d)
                }
                ks.insert(k)
                insertc += 1
            case 1:
                let i = ns[n] % ks.count
                let k = ks[ks.index(ks.startIndex, offsetBy: i)]
                let v = ns[n]
                h[k] = v
                d[k] = v
                XCTAssertEqual(h[k], v)
                XCTAssertEqual(h.count, ec)
                XCTAssertTrue(h == d)
                updatec += 1
            case 2:
                let i = ns[n] % ks.count
                let k = ks[ks.index(ks.startIndex, offsetBy: i)]
                ks.remove(k)
                XCTAssertNotEqual(h[k], nil)
                h[k] = nil
                d[k] = nil
                ec -= 1
                XCTAssertEqual(h[k], nil)
                XCTAssertEqual(h.count, ec)
                XCTAssertTrue(h == d)
                removec += 1
            default:
                fatalError("Bug in test code!")
            }
            print("\(n)/\(c) operations done. (insert/update/remove/count: \(insertc)/\(updatec)/\(removec)/\(h.count))")
        }
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
