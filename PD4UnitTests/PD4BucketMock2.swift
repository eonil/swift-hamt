//
//  PD4Mock2.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/22.
//

import XCTest
import GameKit
@testable import HAMT

/// Insert/update/remove mock.
final class PD4BucketMock2 {
    typealias PDB = PD4Bucket<Mock2Key,String>

    private var r = GKMersenneTwisterRandomSource(seed: 0)
    private(set) var source = [Mock2Key:String]()
    private(set) var target = PDB.topLevel256Bytes()
    private(set) var keyStack = [Mock2Key]()
    private(set) var oldVersionTarget: PDB

    enum Command {
        case insertRandom
        case updateRandom
        case removeRandom
        static let all = [
            .insertRandom,
            .updateRandom,
            .removeRandom,
        ] as [Command]
    }

    init() {
        oldVersionTarget = target
    }

    func runRandom(_ n: Int) {
        for I in 0..<n {
            stepRandom()
        }
    }
    func stepRandom() {
        oldVersionTarget = target
        let n = abs(r.nextInt()) % Command.all.count
        let c = Command.all[n]
        switch c {
        case .insertRandom: insertRandom()
        case .updateRandom: updateRandom()
        case .removeRandom: removeRandom()
        }
    }
    func insertMany(_ n: Int) {
        for _ in 0..<n {
            insertRandom()
            XCTAssertEqual(source.count, target.count)
        }
    }
    func updateMany(_ n: Int) {
        for _ in 0..<n {
            updateRandom()
        }
    }
    func removeAll() {
        keyStack.removeAll()
        for k in source.keys {
            source[k] = nil
            target.set(k, nil)
            XCTAssertEqual(source.count, target.count)
        }
    }
    func getRandom() {
        guard !source.isEmpty else { return }
        let i = r.nextInt(upperBound: keyStack.count)
        let k = keyStack[i]
        let v = source[k]
        let v1 = target.get(k)
        XCTAssertEqual(source.count, target.count)
        XCTAssertEqual(v, v1)
    }
    private func insertRandom() {
        let k = Mock2Key(num: r.nextInt())
        let v = ">"
        guard source.keys.contains(k) == false else { return }
        XCTAssertEqual(target.get(k), nil)
        source[k] = v
        target.set(k, v)
        keyStack.append(k)
        XCTAssertEqual(source.count, target.count)
        XCTAssertEqual(target.get(k), v)
    }
    private func updateRandom() {
        guard !source.isEmpty else { return }
        let i = r.nextInt(upperBound: keyStack.count)
        let k = keyStack[i]
        let v = source[k]! + "."
        source[k] = v
        target.set(k, v)
        XCTAssertEqual(source.count, target.count)
        XCTAssertEqual(target.get(k), v)
    }
    private func removeRandom() {
        guard !source.isEmpty else { return }
        let i = r.nextInt(upperBound: keyStack.count)
        let k = keyStack[i]
        XCTAssertEqual(source[k], target.get(k))
        keyStack.remove(at: i)
        source[k] = nil
        target.set(k, nil)
        XCTAssertEqual(source.count, target.count)
        XCTAssertEqual(target.get(k), nil)
    }
}

struct Mock2Key: Hashable, PD4Hashable {
    private(set) var num: Int
    var hashBits: Int {
        return num
    }
}

