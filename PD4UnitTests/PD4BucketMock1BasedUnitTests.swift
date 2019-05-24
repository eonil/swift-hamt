////
////  PD4BucketMock1BasedUnitTests.swift
////  PD4UnitTests
////
////  Created by Henry on 2019/05/21.
////  Copyright © 2019 Eonil. All rights reserved.
////
//
//import Foundation
//import XCTest
//import GameKit
//@testable import HAMT
//
//class PD4BucketMock1BasedUnitTests: XCTestCase {
//    func testMonteCarlo1() {
//        typealias PDB = PD4Bucket<Int,String>
//        var b = PDB.topLevel256Bytes()
//        var d = [Int:String]()
//        let r = GKMersenneTwisterRandomSource(seed: 0)
//        for i in 0..<2 {
//            let k = r.nextInt()
//            let v = "value \(k) at \(i) iteration."
//            d[k] = v
//            b.set(k, v)
//            let v1 = b.get(k)
//            XCTAssertEqual(v, v1)
//            XCTAssertEqual(d.count, b.count)
//        }
//        let k = r.nextInt()
//        let v = "last value"
//        d[k] = v
//        b.set(k, v)
//        let v1 = b.get(k)
//        XCTAssertEqual(v, v1)
//        XCTAssertEqual(d.count, b.count)
//    }
//    func testMonteCarlo2() {
//        typealias PDB = PD4Bucket<Int,String>
//        var b = PDB.topLevel256Bytes()
//        var d = [Int:String]()
//        let r = GKMersenneTwisterRandomSource(seed: 0)
//        for i in 0..<11 {
//            let k = r.nextInt()
//            let v = "value \(k) at \(i) iteration."
//            d[k] = v
//            b.set(k, v)
//            let v1 = b.get(k)
//            XCTAssertEqual(v, v1)
//            XCTAssertEqual(d.count, b.count)
//        }
//        let k = r.nextInt()
//        let v = "last value"
//        d[k] = v
//        b.set(k, v)
//        let v1 = b.get(k)
//        XCTAssertEqual(v, v1)
//        XCTAssertEqual(d.count, b.count)
//    }
//    func testMonteCarlo3() {
//        typealias Mock = PD4BucketMock1
//        let mock = Mock()
//        mock.runRandom(0xffff)
//        mock.stepRandom()
//    }
//    func testMonteCarlo4() {
//        typealias Mock = PD4BucketMock1
//        let mock = Mock()
//        let n = 0xfff
//        for i in 0..<n {
//            mock.stepRandom()
//            let b = mock.target
//            XCTAssertEqual(b.countAllElements(), b.count)
//            if i % 0xff == 0 {
//                print("#\(i)/\(n), elements: \(b.count)")
//            }
//        }
//    }
//    func testMonteCarlo6() {
//        typealias Mock = PD4BucketMock1
//        let mock = Mock()
//        print("config: \(mock.target.config)")
//        print("max depth: \(mock.target.config.maxLevel())")
//        print("Slot stride: \(MemoryLayout<Mock.PDB.Slot>.stride) bytes")
//        mock.runRandom(163_000)
//        let scap = mock.target.slotCap
//        mock.target.iterateAllBuckets({ b in
//            XCTAssertEqual(b.slotCap, scap)
//        })
//    }
//    func testMonteCarlo7() {
//        typealias Mock = PD4BucketMock1
//        let mock = Mock()
//        print("config: \(mock.target.config)")
//        print("max depth: \(mock.target.config.maxLevel())")
//        print("Slot stride: \(MemoryLayout<Mock.PDB.Slot>.stride) bytes")
//        // about 1 million.
//        let n = 0x100
//        let m = 0x1000
//        for i in 0..<n {
//            let startTime = DispatchTime.now()
//            for _ in 0..<m {
//                mock.stepRandom()
//            }
//            XCTAssertEqual(mock.source.count, mock.target.count)
//            for (k,v) in mock.source {
//                let v1 = mock.target.get(k)
//                XCTAssertEqual(v, v1)
//            }
//
//            let endTime = DispatchTime.now()
//            let timeDelta = Int(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
//            let ec = mock.target.countAllElements()
//            let stat = mock.target.collectStat()
//            XCTAssertEqual(ec, mock.target.count)
//            let mxd = mock.target.countMaxDepth()
//
//            let ss = [
//                "#\((i*m).metricPrefixed)/\((n*m).metricPrefixed)",
//                stat.description,
//                "max-depth: \(mxd)",
//                "\(timeDelta.metricPrefixedNanoSeconds())/\(m)=\((timeDelta/m).metricPrefixedNanoSeconds())",
//            ]
//            print(ss.joined(separator: ", "))
//        }
//    }
//}
