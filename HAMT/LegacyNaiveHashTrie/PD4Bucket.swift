//
//  PD4Bucket.swift
//  PD4
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation


///
/// A bucket of a *hash-trie*.
///
/// DO NOT use this type in user code directly.
/// Exposed internally only for testing.
///
struct PD4Bucket<K,V> where K: PD4Hashable {
    typealias Config = PD4BucketConfig
    typealias Path = PD4HashBitPath
    typealias Slot = PD4BucketSlot<K,V>

    typealias Array = Swift.Array
    typealias Pair = (K,V)

    let config: Config
    private(set) var count = 0
    private(set) var slots: Array<Slot>

    init(config x: Config) {
        config = x
        let c = Int(config.slotCapInBucket)
        slots = Array(repeating: .none, count: c)
        assert(slotCap >= 1)
        assert(slotCap <= Int.max)
    }
    var slotCap: UInt16 {
        return config.slotCapInBucket
    }
    func slotIndex(for k: K) -> Int {
        let h = UInt(bitPattern: k.hashBits)
        let h1 = PD4HashBitPath(h).nextLevel(config: config, times: config.currentLevel)
        return h1.index(config: config)
    }
    func get(_ k: K) -> V? {
        let i = slotIndex(for: k)
        switch slots[i] {
        case .none:
            return nil
        case .unique(let kv):
            return kv.0 == k ? kv.1 : nil
        case .leaf(let a):
            // Worst case. Hash collision occured.
            return a.first(where: { kv in kv.0 == k })?.1
        case .branch(let bu):   return
            bu.get(k)
        }
    }
//    func get(_ h: Path, _ k: K) -> V? {
//        let i = h.index(config: config)
//        switch slots[i] {
//        case .none:
//            return nil
//        case .unique(let kv):
//            return kv.0 == k ? kv.1 : nil
//        case .leaf(let a):
//            // Worst case. Hash collision occured.
//            return a.first(where: { kv in kv.0 == k })?.1
//        case .branch(let bu):   return
//            bu.get(h.nextLevel(config: config), k)
//        }
//    }
    mutating func set(_ k: K, _ v: V?) {
        let h = k.pathify()
        set(h, k, v)
    }
    mutating func set(_ h: Path, _ k: K, _ v: V?) {
        if let v = v {
            insertOrReplace(h, k, v)
        }
        else {
            removeOrIgnore(h, k)
        }
    }

    /// Returns `true` if new one has been inserted.
    /// Returns `false` if existing one has been replaced.
    enum InsertOrReplaceResult {
        case inserted
        case replaced
    }
    @discardableResult
    mutating func insertOrReplace(_ h: Path, _ k: K, _ v: V) -> InsertOrReplaceResult {
        let i = slotIndex(for: k)
        switch slots[i] {
        case .none:
            precondition(count < .max, "Out of space.")
            let kv = (k,v)
            slots[i] = .unique(kv)
            count += 1
            return .inserted
        case .unique(let kv):
            if kv.0 == k {
                // Unique replacement.
                let kv1 = (k, v)
                slots[i] = .unique(kv1)
                return .replaced
            }
            else {
                if config.isFinalBranch {
                    // Hash collided.
                    // No more depth can be created.
                    // Promote to leaf and insert.
                    precondition(count < .max, "Out of space.")
                    let kv1 = (k,v)
                    slots[i] = .leaf([kv, kv1])
                    count += 1
                    return .inserted
                }
                else {
                    // Promote unique to branch and insert.
                    let h1 = h.nextLevel(config: config)
                    var bu = PD4Bucket(config: config.nextLevel())
                    assert(bu.config.currentLevel < bu.config.maxLevel())
                    bu.insertOrReplace(h1, kv.0, kv.1)
                    bu.insertOrReplace(h1, k, v)
                    slots[i] = .branch(bu)
                    count += 1
                    return .inserted
                }
            }

        case .leaf(var a):
            for j in 0..<a.count {
                if a[j].0 == k {
                    // Replace.
                    a[j].1 = v
                    slots[i] = .leaf(a)
                    return .replaced
                }
            }
            // No more replace. Insertion only scenario.
            // Hash collided. No more depth can be created.
            // Insert in place.
            precondition(count < .max, "Out of space.")
            a.append((k,v))
            slots[i] = .leaf(a)
            count += 1
            return .inserted

        case .branch(var b):
            let h1 = h.nextLevel(config: config)
            switch b.insertOrReplace(h1, k, v) {
            case .inserted:
                slots[i] = .branch(b)
                count += 1
                return .inserted
            case .replaced:
                slots[i] = .branch(b)
                return .replaced
            }
        }
    }

    enum RemoveOrIgnoreResult {
        case removed
        case ignored
    }
    @discardableResult
    mutating func removeOrIgnore(_ h: Path, _ k: K) -> RemoveOrIgnoreResult {
        let i = slotIndex(for: k)
        switch slots[i] {
        case .none:
            return .ignored
        case .unique(let kv):
            if kv.0 == k {
                count -= 1
                slots[i] = .none
                return .removed
            }
            else {
                // Ignore.
                return .ignored
            }
        case .leaf(var a):
            for j in a.indices {
                if a[j].0 == k {
                    a.remove(at: j)
                    if a.count == 1 {
                        // Promote to unique slot.
                        count -= 1
                        slots[i] = .unique(a[0])
                        return .removed
                    }
                    else {
                        count -= 1
                        slots[i] = .leaf(a)
                        return .removed
                    }
                }
            }
            return .ignored
        case .branch(var b):
            let h1 = h.nextLevel(config: config)
            switch b.removeOrIgnore(h1, k) {
            case .ignored:
                return .ignored
            case .removed:
                count -= 1
                switch b.count {
                case 0:
                    slots[i] = .none
                case 1:
                    // Promote to unique slot.
                    // TODO: Make up a regular iterator.
                    var kv: Pair?
                    b.iterate({ kv1 in
                        kv = kv1
                    })
                    slots[i] = .unique(kv!)
                default:
                    slots[i] = .branch(b)
                    break
                }
                return .removed
            }
        }
    }
}

extension PD4Bucket {
    func iterate(_ fx: (Pair) -> Void) {
        for slot in slots {
            switch slot {
            case .none:
                break
            case .unique(let kv):
                fx(kv)
            case .leaf(let a):
                for kv in a {
                    fx(kv)
                }
            case .branch(let bu):
                bu.iterate(fx)
            }
        }
    }
}


