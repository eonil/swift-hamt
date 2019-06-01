//
//  main.swift
//  PD4PerfTool
//
//  Created by Henry on 2019/05/22.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import GameKit

let averageCount = 100
let outerLoopCount = 1_00
let innerLoopCount = 1_000

///
/// returns list of nanoseconds for each outer iteration.
///
func run(_ single_op: (Int) -> Void) -> [Double] {
    var data = [Double]()
    for i in 0..<outerLoopCount {
        let startTime = DispatchTime.now()
        for j in 0..<innerLoopCount {
            let k = i * innerLoopCount + j
            single_op(k)
        }
        let endTime = DispatchTime.now()
        let timeDelta = Int(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
        let timeDeltaSingleOp = Double(timeDelta) / Double(innerLoopCount)
        data.append(timeDeltaSingleOp)

        if (i+1) % (outerLoopCount/10) == 0 {
            let d = timeDelta / innerLoopCount
            print("  \(i+1)k: \(d.metricPrefixedNanoSeconds())")
        }
        if timeDelta > 50_000_000 {
            print(" iteration takes over 50ms. and too slow. cancel test.")
            return data
        }
    }
    return data
}

func clearCache() {
    do {
        // Clear cache.
        var a = [UInt32](repeating: 0, count: 1024 * 1024 * 128)
        for i in 0..<a.count {
            a[i] = arc4random()
        }
        var b = 0 as UInt32
        for i in 0..<a.count {
            b += a[i]
        }
        print(b)
    }
}

var db = DB(iterationCount: averageCount)

protocol AAPerfMeasuringProtocol {
    associatedtype Key
    associatedtype Value
    init()
    var count: Int { get }
    subscript(key: Key) -> Value? { get set }
}
extension Dictionary: AAPerfMeasuringProtocol {}
extension Map: AAPerfMeasuringProtocol {}
extension HAMT: AAPerfMeasuringProtocol {}

struct CRUDNames {
    var get: DB.Name
    var insert: DB.Name
    var update: DB.Name
    var remove: DB.Name
}

func runCRUDPackage<T>(_: T.Type, _ ns: CRUDNames) where T: AAPerfMeasuringProtocol, T.Key == Int, T.Value == Int {
    for i in 0..<averageCount {
        do {
            let n = ns.get
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            let ks = Array(0..<m).shuffled()
            var pd = T()
            for i in 0..<m {
                pd[i] = i
            }
            precondition(pd.count == m)

            var pd1 = pd
            let ss = run { i in
                let k = ks[i]
                let v = pd[k]!
                pd1 = pd
                precondition(v == k)
                precondition(pd1.count == pd.count)
            }
            precondition(pd.count == m)
            precondition(pd1.count == pd.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
        do {
            let n = ns.insert
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            let ks = Array(0..<m).shuffled()
            var pd = T()
            var pd1 = pd // Keep one copy to test persistency.
            let ss = run { i in
                let k = ks[i]
                pd[k] = i
                pd1 = pd
            }
            precondition(pd.count == pd1.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
        do {
            let n = ns.update
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            let ks = Array(0..<m).shuffled()
            var pd = T()
            for i in 0..<m {
                pd[i] = i
            }
            precondition(pd.count == m)

            var pd1 = pd
            let ss = run { i in
                let k = ks[i]
                pd[k] = i
                pd1 = pd
                precondition(pd1.count == pd.count)
            }
            precondition(pd.count == m)
            precondition(pd1.count == pd.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
        do {
            let n = ns.remove
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            var ks = Array(0..<m).shuffled()
            var pd = T()
            for i in 0..<m {
                pd[i] = i
            }
            precondition(pd.count == m)

            var pd1 = pd
            let ss = run { i in
                let k = ks.removeLast()
                pd[k] = nil
                pd1 = pd
                precondition(pd.count == ks.count)
                precondition(pd1.count == pd.count)
            }
            precondition(pd.count == ks.count)
            precondition(pd1.count == pd.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
    }
}

runCRUDPackage(Dictionary<Int,Int>.self, CRUDNames(
    get: .stdGet,
    insert: .stdInsert,
    update: .stdUpdate,
    remove: .stdRemove))
runCRUDPackage(Map<Int,Int>.self, CRUDNames(
    get: .btreeGet,
    insert: .btreeInsert,
    update: .btreeUpdate,
    remove: .btreeRemove))
runCRUDPackage(HAMT<Int,Int>.self, CRUDNames(
    get: .pd5Get,
    insert: .pd5Insert,
    update: .pd5Update,
    remove: .pd5Remove))
db.print()
