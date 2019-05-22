//
//  PD5IterationUnitTests.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/24.
//

import Foundation
import XCTest
@testable import SwiftHashTrie

class PD5IterationUnitTests: XCTestCase {
    func test2() {
        typealias K = PD5MocklessTestKey
        typealias PDB = PD5Bucket64<K,Int>
        typealias Pair = PD5Pair<K,Int>
        var b = PDB()
        XCTAssertEqual(Array(b.dfsSlots), [])
        b.insertOrReplace(K(1).hashBits, K(1), 1)
        XCTAssertEqual(Array(b.dfsSlots), [.unique(Pair(K(1),1))])
        b.insertOrReplace(K(1).hashBits, K(1), 1)
        XCTAssertEqual(Array(b.dfsSlots), [.unique(Pair(K(1),1))])
        b.insertOrReplace(K(2).hashBits, K(2), 2)
        XCTAssertEqual(Array(b.dfsSlots), [.unique(Pair(K(1),1)), .unique(Pair(K(2),2))])
    }
    func test3() {
        typealias K = PD5MocklessTestKey
        typealias PDB = PD5Bucket64<K,Int>
        typealias Pair = PD5Pair<K,Int>
        var b = PDB()
        for i in 0..<64 {
            b.insertOrReplace(K(i).hashBits, K(i), i)
        }
        XCTAssertEqual(Array(b.dfsSlots).compactMap({ s in s.unique?.value }), Array(0..<64))
        b.insertOrReplace(K(111).hashBits, K(111), 111)
        // 111 = 0b0_0110_1111
        // last 6 bits is 0b0_10_1111 = 47
        let s = b.slots.get1(index: 47)
        XCTAssertNotNil(s)
        XCTAssertNotNil(s!.branch)
        XCTAssertEqual(s!.branch!.slots.count, 2)
        let ss = s!.branch!.slots
        // key/value 47 moved into higher level.
        XCTAssertEqual(ss.get1(index: 0)?.unique?.value, 47)
        XCTAssertEqual(ss.get1(index: 1)?.unique?.value, 111)

        var it = b.dfsSlots.makeIterator()
        for i in 0..<47 {
            let s = it.next()
            XCTAssertEqual(s?.unique?.value, i)
        }
        do {
            let s = it.next()
            XCTAssertNotNil(s?.branch)
        }
        // Nove it should move up to first child.
        do {
            let s1 = it.next()
            XCTAssertEqual(s1?.unique?.value, 47)
            let s2 = it.next()
            XCTAssertEqual(s2?.unique?.value, 111)
        }
        // Now all children has been iterated.
        // Move down to the lower level.
        for i in 48..<64 {
            let s = it.next()
            XCTAssertEqual(s?.unique?.value, i)
        }
        do {
            let a = Array(b.dfsSlots).compactMap({ s in s.unique?.value })
            let b = Array(0..<47) + [47,111] + Array(48..<64)
            XCTAssertEqual(a, b)
        }
        do {
            let a = Array(b.dfsSlots)
            let b = a.map({ s in s.currentLevelPairs })
            do {
                let x = b[0]
                let y = Array(x)
                XCTAssertEqual(y.count, 1)
            }
            let c = Array(b.map({ clp in Array(clp) }))
            XCTAssertEqual(a.count, 64+2)
            XCTAssertEqual(b.count, 64+2)
            XCTAssertEqual(c.count, 64+2)
        }
        do {
            let a = Array(b.pairs).map({ $0.value })
            let b = Array(0..<47) + [47,111] + Array(48..<64)
            XCTAssertEqual(a, b)
        }
    }
    func test4() {
        typealias K = PD5MocklessTestKey
        typealias SD = [K:Int]
        typealias PDB = PD5Bucket64<K,Int>
        var b = PDB()
        b[K(111)] = 222
        XCTAssertEqual(Array(b.pairs), [PDB.Pair(K(111), 222)])
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

private extension PD5Slot64 {
    var unique: Pair? {
        switch self {
        case .unique(let p):    return p
        default:                return nil
        }
    }
    var branch: Bucket? {
        switch self {
        case .branch(let b):    return b
        default:                return nil
        }
    }
}
