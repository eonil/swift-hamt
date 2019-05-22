//
//  PD4BucketMock2BasedUnitTests.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/22.
//

import Foundation
import XCTest
import GameKit
@testable import SwiftHashTrie

class PD4BucketMock2BasedUnitTests: XCTestCase {
    func testCase1() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        mock.runRandom(6)
        mock.stepRandom()
    }
    func testCase2() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        mock.runRandom(40)
        mock.stepRandom()
    }
    func testCase3() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        for i in 0..<60564 {
            mock.stepRandom()
        }
        // here key 1436747215 should be survived after stepping.
        mock.stepRandom()
        for k in mock.source.keys {
            XCTAssertEqual(mock.source[k], mock.target.get(k))
        }
    }

    func testMonteCarlo3() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        mock.runRandom(0xffff)
        mock.stepRandom()
    }
    func testMonteCarlo4() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        let n = 0xfff
        for i in 0..<n {
            mock.stepRandom()
            let b = mock.target
            XCTAssertEqual(b.countAllElements(), b.count)
            if i % 0xff == 0 {
                print("#\(i)/\(n), elements: \(b.count)")
            }
        }
    }
    func testMonteCarlo6() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        print("config: \(mock.target.config)")
        print("max depth: \(mock.target.config.maxLevel())")
        print("Slot stride: \(MemoryLayout<Mock.PDB.Slot>.stride) bytes")
        mock.runRandom(163_000)
        let scap = mock.target.slotCap
        mock.target.iterateAllBuckets({ b in
            XCTAssertEqual(b.slotCap, scap)
        })
    }
    func testMonteCarlo7() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        print("config: \(mock.target.config)")
        print("max depth: \(mock.target.config.maxLevel())")
        print("Slot stride: \(MemoryLayout<Mock.PDB.Slot>.stride) bytes")
        // n * m = 1 Mi
        let n = 0x100
        let m = 0x1000
        for i in 0..<n {
            let startTime = DispatchTime.now()
            for _ in 0..<m {
                mock.stepRandom()
            }
            XCTAssertEqual(mock.source.count, mock.target.count)
            for (k,v) in mock.source {
                let v1 = mock.target.get(k)
                XCTAssertEqual(v, v1)
            }

            let endTime = DispatchTime.now()
            let timeDelta = Int(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
            let ec = mock.target.countAllElements()
            let stat = mock.target.collectStat()
            XCTAssertEqual(ec, mock.target.count)
            let mxd = mock.target.countMaxDepth()

            let ss = [
                "#\((i*m).metricPrefixed)/\((n*m).metricPrefixed)",
                stat.description,
                "max-depth: \(mxd)",
                "\(timeDelta.metricPrefixedNanoSeconds())/\(m)=\((timeDelta/m).metricPrefixedNanoSeconds())",
            ]
            print(ss.joined(separator: ", "))
        }
    }
    func testMonteCarlo8() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        print("config: \(mock.target.config)")
        print("max depth: \(mock.target.config.maxLevel())")
        print("Slot stride: \(MemoryLayout<Mock.PDB.Slot>.stride) bytes")
        for i in 0..<100 {
            mock.insertMany(10_000)
            print("#\(i): insert many count \(mock.target.count.metricPrefixed)")
        }
        for i in 0..<100 {
            mock.runRandom(10_000)
            print("#\(i): run random count \(mock.target.count.metricPrefixed)")
        }
        
        mock.removeAll()
    }
    func testMonteCarlo9() {
        typealias Mock = PD4BucketMock2
        let mock = Mock()
        print("config: \(mock.target.config)")
        print("max depth: \(mock.target.config.maxLevel())")
        print("Slot stride: \(MemoryLayout<Mock.PDB.Slot>.stride) bytes")
        for i in 0..<100 {
            mock.insertMany(10_000)
            print("#\(i): count \(mock.target.count.metricPrefixed)")
        }

        // n * m = 1 Mi
        let n = 0x100
        let m = 0x1000
        for i in 0..<n {
            let startTime = DispatchTime.now()
            for _ in 0..<m {
                mock.getRandom()
            }
            XCTAssertEqual(mock.source.count, mock.target.count)
            for (k,v) in mock.source {
                let v1 = mock.target.get(k)
                XCTAssertEqual(v, v1)
            }

            let endTime = DispatchTime.now()
            let timeDelta = Int(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
            let ec = mock.target.countAllElements()
            let stat = mock.target.collectStat()
            XCTAssertEqual(ec, mock.target.count)
            let mxd = mock.target.countMaxDepth()

            let ss = [
                "#\((i*m).metricPrefixed)/\((n*m).metricPrefixed)",
                stat.description,
                "max-depth: \(mxd)",
                "\(timeDelta.metricPrefixedNanoSeconds())/\(m)=\((timeDelta/m).metricPrefixedNanoSeconds())",
            ]
            print(ss.joined(separator: ", "))
        }

        mock.removeAll()
    }
}
