//
//  PD5CompressedTableUnitTests.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/24.
//

import Foundation
import XCTest
@testable import SwiftHashTrie

class PD5CompressedTableUnitTests: XCTestCase {
    func test1() {
        var ct = PD5CompressedTable64<Int>()
        for i in 0..<64 {
            XCTAssertEqual(Array(ct), Array(0..<i))
            ct.set(index: UInt(i), i)
        }
        XCTAssertEqual(Array(ct), Array(0..<64))
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
