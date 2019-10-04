//
//  File.swift
//  
//
//  Created by Henry Hathaway on 10/4/19.
//

import Foundation
import XCTest
import GameKit
@testable import HAMT

final class HAMTTests: XCTestCase {
    func testRemoveAll() {
        var x = HAMT<Int,Int>()
        x[111] = 222
        x[222] = 444
        x[333] = 666
        XCTAssertEqual(x.count, 3)
        x.removeAll()
        XCTAssertEqual(x.count, 0)
    }
}
