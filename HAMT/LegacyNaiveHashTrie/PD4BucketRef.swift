////
////  PD4BucketRef.swift
////  PD5UnitTests
////
////  Created by Henry on 2019/05/22.
////
//
//import Foundation
//
//struct PD4Bucket<K,V> where K: PD4Hashable {
//    typealias Config = PD4BucketConfig
//    typealias Slot = PD4BucketSlot<K,V>
//
//    typealias Array = Swift.ContiguousArray
//    typealias Pair = (K,V)
//
//    private var ref: PD4BucketRef<K,V>
//    init(config x: PD4BucketConfig) {
//        ref = PD4BucketRef(config: x)
//    }
//    var config: Config {
//        return ref.config
//    }
//    var count: Int {
//        return ref.count
//    }
//    var slots: Array<Slot> {
//        return ref.slots
//    }
//    func get(_ k: K) -> V? {
//        return ref.get(k)
//    }
//    mutating func set(_ k: K, _ v: V?) {
//        if !isKnownUniquelyReferenced(&ref) {
//            ref = PD4BucketRef(copying: ref)
//        }
//        ref.set(k, v)
//    }
//    mutating func insertOrReplace(_ k: K, _ v: V) -> PD4BucketRef<K,V>.InsertOrReplaceResult {
//        if !isKnownUniquelyReferenced(&ref) {
//            ref = PD4BucketRef(copying: ref)
//        }
//        return ref.insertOrReplace(k, v)
//    }
//    mutating func removeOrIgnore(_ k: K) -> PD4BucketRef<K,V>.RemoveOrIgnoreResult {
//        if !isKnownUniquelyReferenced(&ref) {
//            ref = PD4BucketRef(copying: ref)
//        }
//        return ref.removeOrIgnore(k)
//    }
//}
//
/////
///// A bucket of a *hash-trie*.
/////
///// DO NOT use this type in user code directly.
///// Exposed internally only for testing.
/////
//final class PD4BucketRef<K,V> where K: PD4Hashable {
//    typealias Config = PD4BucketConfig
//    typealias Slot = PD4BucketSlot<K,V>
//
//    typealias Array = Swift.ContiguousArray
//    typealias Pair = (K,V)
//
//    let config: Config
//    private(set) var count = 0
//    private(set) var slots: Array<Slot>
//
//    init(copying src: PD4BucketRef) {
//        config = src.config
//        count = src.count
//        slots = src.slots
//    }
//    init(config x: Config) {
//        config = x
//        let c = config.bucketCapInBytes / MemoryLayout<Slot>.stride
//        slots = Array(repeating: .none, count: c)
//        assert(slotCap >= 1)
//        assert(slotCap <= Int.max)
//    }
//
//    var slotCap: Int {
//        return config.bucketCapInBytes / MemoryLayout<Slot>.stride
//    }
//
//    var pairCap: Int {
//        return config.bucketCapInBytes / MemoryLayout<Pair>.stride
//    }
//
//    func slotIndex(for k: K) -> Int {
//        let h = UInt(bitPattern: k.hashBits)
//        let n = Int(config.currentLevel * config.bitCountPerLevel)
//        let m = BitArray(h).capture((n - Int(config.bitCountPerLevel))..<n)
//        let i = m.bits % UInt(slotCap)
//        return Int(i)
//    }
//    func get(_ k: K) -> V? {
//        let i = slotIndex(for: k)
//        switch slots[i] {
//        case .none:             return nil
//        case .leaf(let a):      return a.first(where: { kv in kv.0 == k })?.1
//        case .branch(let bu):   return bu.get(k)
//        }
//    }
//    func set(_ k: K, _ v: V?) {
//        if let v = v {
//            insertOrReplace(k, v)
//        }
//        else {
//            removeOrIgnore(k)
//        }
//    }
//
//    /// Returns `true` if new one has been inserted.
//    /// Returns `false` if existing one has been replaced.
//    enum InsertOrReplaceResult {
//        case inserted
//        case replaced
//    }
//    @discardableResult
//    func insertOrReplace(_ k: K, _ v: V) -> InsertOrReplaceResult {
//        let i = slotIndex(for: k)
//        switch slots[i] {
//        case .none:
//            precondition(count < .max, "Out of space.")
//            let kv = (k,v)
//            slots[i] = .leaf([kv])
//            count += 1
//            return .inserted
//        case .leaf(var a):
//            for j in 0..<a.count {
//                if a[j].0 == k {
//                    // Replace.
//                    a[j].1 = v
//                    slots[i] = .leaf(a)
//                    return .replaced
//                }
//            }
//            // No more replace. Insertion only scenario.
//            precondition(count < .max, "Out of space.")
//            let isAtMaxLevel = config.currentLevel + 1 == config.maxLevel()
//            if isAtMaxLevel || a.count < pairCap {
//                // Insert in place.
//                a.append((k,v))
//                slots[i] = .leaf(a)
//                count += 1
//                assert(a.count <= pairCap)
//                return .inserted
//            }
//            else {
//                // Convert to bucket and insert.
//                // As we processed replacement above
//                // here we never go for replacement.
//                var bu = PD4Bucket<K,V>(config: config.nextLevel())
//                assert(bu.config.currentLevel < bu.config.maxLevel())
//                for kv in a {
//                    bu.insertOrReplace(kv.0, kv.1)
//                }
//                bu.insertOrReplace(k, v)
//                slots[i] = .branch(bu)
//                count += 1
//                return .inserted
//            }
//        case .branch(var bu):
//            switch bu.insertOrReplace(k, v) {
//            case .inserted:
//                slots[i] = .branch(bu)
//                count += 1
//                return .inserted
//            case .replaced:
//                slots[i] = .branch(bu)
//                return .replaced
//            }
//        }
//    }
//
//    enum RemoveOrIgnoreResult {
//        case removed
//        case ignored
//    }
//    @discardableResult
//    func removeOrIgnore(_ k: K) -> RemoveOrIgnoreResult {
//        let i = slotIndex(for: k)
//        switch slots[i] {
//        case .none:
//            return .ignored
//        case .leaf(var a):
//            for j in a.indices {
//                if a[j].0 == k {
//                    a.remove(at: j)
//                    if a.isEmpty {
//                        count -= 1
//                        slots[i] = .none
//                        return .removed
//                    }
//                    else {
//                        count -= 1
//                        slots[i] = .leaf(a)
//                        return .removed
//                    }
//                }
//            }
//            return .ignored
//        case .branch(var bu):
//            //            if bu.count <= (pairCap / 2) {
//            if bu.count <= pairCap {
//                // Convert to in-cap.
//                // Always convert regardless of remove or ignore.
//                var a = Array<Pair>()
//                a.reserveCapacity(pairCap)
//                bu.iterate({ kv in
//                    if kv.0 != k {
//                        a.append(kv)
//                    }
//                })
//
//                if a.count < bu.count {
//                    // Removed.
//                    slots[i] = .leaf(a)
//                    count -= 1
//                    return .removed
//                }
//                else {
//                    // Ignored.
//                    slots[i] = .leaf(a)
//                    return .ignored
//                }
//            }
//            else {
//                switch bu.removeOrIgnore(k) {
//                case .removed:
//                    slots[i] = .branch(bu)
//                    count -= 1
//                    return .removed
//                case .ignored:
//                    return .ignored
//                }
//            }
//
//        }
//    }
//}
//
//extension PD4Bucket {
//    func iterate(_ fx: (Pair) -> Void) {
//        for slot in slots {
//            switch slot {
//            case .none:
//                break
//            case .leaf(let a):
//                for kv in a {
//                    fx(kv)
//                }
//            case .branch(let bu):
//                bu.iterate(fx)
//            }
//        }
//    }
//}
