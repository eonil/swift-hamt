//
//  PD4BucketMocklessUnitTests.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/22.
//

import Foundation
import XCTest
import GameKit
@testable import SwiftHashTrie

class PD4BucketMocklessBasedUnitTests: XCTestCase {
//    func testCase1() {
//        XCTAssertLessThan(MemoryLayout<PD4BucketSlot<Int,Int>>.size, MemoryLayout<Int>.size)
//    }

    func testCase2() {
        typealias PDB = PD4Bucket<Int,String>
        var b = PDB.topLevel256Bytes()
        b.set(111, "a")
        XCTAssertEqual(b.get(111), "a")
        XCTAssertEqual(b.count, 1)
        b.set(111, nil)
        XCTAssertEqual(b.get(111), nil)
        XCTAssertEqual(b.count, 0)

        b.set(111, "a")
        b.set(222, "b")
        b.set(333, "c")
        b.set(444, "d")
        b.set(555, "e")
        XCTAssertEqual(b.get(111), "a")
        XCTAssertEqual(b.get(222), "b")
        XCTAssertEqual(b.get(333), "c")
        XCTAssertEqual(b.get(444), "d")
        XCTAssertEqual(b.get(555), "e")
        b.set(111, nil)
        b.set(222, nil)
        b.set(333, nil)
        b.set(444, nil)
        b.set(555, nil)
        XCTAssertEqual(b.count, 0)
        XCTAssertEqual(b.get(111), nil)
        XCTAssertEqual(b.get(222), nil)
        XCTAssertEqual(b.get(333), nil)
        XCTAssertEqual(b.get(444), nil)
        XCTAssertEqual(b.get(555), nil)
    }

    func testMonteCarlo1() {
        typealias PDB = PD4Bucket<Int,String>
        var b = PDB.topLevel256Bytes()
        var d = [Int:String]()
        let r = GKMersenneTwisterRandomSource(seed: 0)
        for i in 0..<2 {
            let k = r.nextInt()
            let v = "value \(k) at \(i) iteration."
            d[k] = v
            b.set(k, v)
            let v1 = b.get(k)
            XCTAssertEqual(v, v1)
            XCTAssertEqual(d.count, b.count)
        }
        let k = r.nextInt()
        let v = "last value"
        d[k] = v
        b.set(k, v)
        let v1 = b.get(k)
        XCTAssertEqual(v, v1)
        XCTAssertEqual(d.count, b.count)
    }
    func testMonteCarlo2() {
        typealias PDB = PD4Bucket<Int,String>
        var b = PDB.topLevel256Bytes()
        var d = [Int:String]()
        let r = GKMersenneTwisterRandomSource(seed: 0)
        for i in 0..<11 {
            let k = r.nextInt()
            let v = "value \(k) at \(i) iteration."
            d[k] = v
            b.set(k, v)
            let v1 = b.get(k)
            XCTAssertEqual(v, v1)
            XCTAssertEqual(d.count, b.count)
        }
        let k = r.nextInt()
        let v = "last value"
        d[k] = v
        b.set(k, v)
        let v1 = b.get(k)
        XCTAssertEqual(v, v1)
        XCTAssertEqual(d.count, b.count)
    }
}
