//
//  PD4.utility.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
@testable import SwiftHashTrie

extension PD4Bucket {
//    func indexPath(of k: K) -> IndexPath? {
//        let i = slotIndex(for: k)
//        switch slots[i] {
//        case .none:
//            return nil
//        case .unique(_):
//            return [i]
//        case .branch(let bu):
//            guard let idxp1 = bu.indexPath(of: k) else { return nil }
//            return IndexPath(index: i).appending(idxp1)
//        case .leaf(let a):
//            guard let j = a.firstIndex(where: { kv in kv.0 == k }) else { return nil }
//            return [i,j]
//        }
//    }

    func countAllBranchBuckets() -> Int {
        var c = 1
        for s in slots {
            switch s {
            case .none:             break
            case .unique(_):        break
            case .branch(let b):    c += b.countAllBranchBuckets()
            case .leaf(_):          break
            }
        }
        return c
    }
    func countAllLeafNode() -> Int {
        var c = 0
        for s in slots {
            switch s {
            case .none:             break
            case .unique(_):        break
            case .branch(let b):    c += b.countAllLeafNode()
            case .leaf(_):          c += 1
            }
        }
        return c
    }
    func countAllElements() -> Int {
        var c = 0
        for s in slots {
            switch s {
            case .none:             break
            case .unique(_):        c += 1
            case .branch(let b):    c += b.countAllElements()
            case .leaf(let a):      c += a.count
            }
        }
        return c
    }
    func countMaxDepth() -> Int {
        var d = 1
        for s in slots {
            switch s {
            case .none:             break
            case .unique(_):        break
            case .branch(let b):    d = max(d,1 + b.countMaxDepth())
            case .leaf(_):          d = max(d,2)
            }
        }
        return d
    }



    func iterateAllBuckets(_ fx: (PD4Bucket) -> Void) {
        fx(self)
        for slot in slots {
            switch slot {
            case .none:             break
            case .unique(_):        break
            case .branch(let b):    b.iterateAllBuckets(fx)
            case .leaf(_):          break
            }
        }
    }
    func iterateAllLeafNodeHashCollidedArrays(_ fx: (Array<Pair>) -> Void) {
        for slot in slots {
            switch slot {
            case .none:             break
            case .unique(_):        break
            case .branch(let b):    b.iterateAllLeafNodeHashCollidedArrays(fx)
            case .leaf(let a):      fx(a)
            }
        }
    }
    func iterateAllBranchNodeSlotArrays(_ fx: (Array<Slot>) -> Void) {
        fx(slots)
        for slot in slots {
            switch slot {
            case .none:             break
            case .unique(_):        break
            case .branch(let b):    b.iterateAllBranchNodeSlotArrays(fx)
            case .leaf(_):          break
            }
        }
    }
}
