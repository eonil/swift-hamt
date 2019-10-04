//
//  File.swift
//  
//
//  Created by Henry Hathaway on 10/4/19.
//

import Foundation
import HAMT
import GameKit

// This test is too slow without optimization...
// Uses irreproducible random, therefore this test
// is not reproducible.
let c = 1_00_000
var h = HAMT<Int,Int>()
var d = [Int:Int]()
let ns = Array(0..<c).shuffled()
var ks = Set<Int>(0..<c)
for i in 0..<c {
    preconditionEqual(h.count, i)
    h[i] = i
    d[i] = i
    preconditionEqual(h[i], i)
    if i % 1_000 == 0 {
        print("\(i)/\(c) inserted.")
    }
}
preconditionEqual(h.count, c)

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
            preconditionEqual(h[k], k)
            preconditionEqual(h.count, ec)
            precondition(h == d)
        }
        ks.insert(k)
        insertc += 1
    case 1:
        let i = ns[n] % ks.count
        let k = ks[ks.index(ks.startIndex, offsetBy: i)]
        let v = ns[n]
        h[k] = v
        d[k] = v
        preconditionEqual(h[k], v)
        preconditionEqual(h.count, ec)
        precondition(h == d)
        updatec += 1
    case 2:
        let i = ns[n] % ks.count
        let k = ks[ks.index(ks.startIndex, offsetBy: i)]
        ks.remove(k)
        precondition(h[k] != nil)
        h[k] = nil
        d[k] = nil
        ec -= 1
        preconditionEqual(h[k], nil)
        preconditionEqual(h.count, ec)
        precondition(h == d)
        removec += 1
    default:
        fatalError("Bug in test code!")
    }
    print("\(n)/\(c) operations done. (insert/update/remove/count: \(insertc)/\(updatec)/\(removec)/\(h.count))")
}

