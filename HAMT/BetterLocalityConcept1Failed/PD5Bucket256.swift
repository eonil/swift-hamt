////
////  PD5Bucket256.swift
////  SwiftHashTrie-macOS
////
////  Created by Henry on 2019/05/23.
////
//
//private let hashBitCountPerLevel = UInt(8) // 2^8 = 256 bits.
//private let hashBitMaskPerLevel = UInt(0b0_1111_1111)
//private let maxLevelCount = UInt8(UInt(256) / hashBitCountPerLevel)
//private let maxLevelIndex = UInt8(UInt(256) / hashBitCountPerLevel - 1)
//
/////
///// A 256-bit HAMT node.
/////
///// One 256-bit HAMT node has 256 slots. There's no way to
///// adjust this size dynamically.
/////
//struct PD5Bucket256<K,V> where K: PD5Hashable {
//    typealias Slot = PD5Slot256<K,V>
//    typealias Pair = PD5Pair<K,V>
//    private(set) var config = PD5BucketConfig()
//    /// Total count of all elements in this subtree.
//    private(set) var sum = 0
//    private(set) var slots = PD5CompressedTable256<Slot>()
//
//    @inlinable
//    @inline(__always)
//    init() {}
//
//    @inline(__always)
//    private init(config x: PD5BucketConfig) {
//        precondition(x.level < maxLevelCount)
//        config = x
//    }
//    @inlinable
//    @inline(__always)
//    var count: Int {
//        return sum
//    }
//    @inlinable
//    @inline(__always)
//    subscript(_ k: K) -> V? {
//        get {
//            let h = k.hashBits
//            return find(h, k)
//        }
//        set(v) {
//            let h = k.hashBits
//            if let v = v {
//                insertOrReplace(h, k, v)
//            }
//            else {
//                removeOrIgnore(h, k)
//            }
//        }
//    }
//
//    @inlinable
//    @inline(__always)
//    subscript(_ k: K, default defv: @autoclosure() -> V) -> V {
//        get {
//            let h = k.hashBits
//            return find(h, k) ?? defv()
//        }
//        set(v) {
//            let h = k.hashBits
//            insertOrReplace(h, k, v)
//        }
//    }
//
//    @inlinable
//    @inline(__always)
//    func slotIndex(for h: UInt) -> UInt {
//        let h1 = h >> (hashBitCountPerLevel * UInt(config.level))
//        let ik = h1 & hashBitMaskPerLevel
//        return ik
//    }
//    @inlinable
//    @inline(__always)
//    func find(_ h: UInt, _ k: K) -> V? {
//        //        let ik = slotIndex(for: h)
//        //        let slot = slots.get(index: ik, default: .none)
//        //        switch slot {
//        //        case .none:             return nil
//        //        case .unique(let kv):   return kv.key == k ? kv.value : nil
//        //        case .branch(let b):    return b.find(h, k)
//        //        case .leaf(let a):      return a.first(where: { kv in kv.key == k })?.value
//        //        }
//        return findWithPreshiftedHashBits(h, k)
//    }
//    @inline(__always)
//    private func findWithPreshiftedHashBits(_ h: UInt, _ k: K) -> V? {
//        var h1 = h
//        var b = self
//        while true {
//            let ik = h1 & hashBitMaskPerLevel
//            let slot = b.slots.get(index: ik) ?? .none
//            switch slot {
//            case .none:             return nil
//            case .unique(let kv):   return kv.key == k ? kv.value : nil
//            case .branch(let b1):
//                b = b1
//                h1 = h1 >> hashBitCountPerLevel
//            case .leaf(let a):      return a.first(where: { kv in kv.key == k })?.value
//            }
//        }
//    }
//
//    enum InsertOrReplaceResult {
//        case inserted
//        case replaced(V)
//    }
//    @inlinable
//    @inline(__always)
//    @discardableResult
//    mutating func insertOrReplace(_ h: UInt, _ k: K, _ v: V) -> InsertOrReplaceResult {
//        let ik = slotIndex(for: h)
//        let s = slots.get(index: ik) ?? .none
//        switch s {
//        case .none:
//            slots.set(index: ik, .unique(Pair(k,v)))
//            sum += 1
//            return .inserted
//        case .unique(let kv):
//            if kv.key == k {
//                // Replace.
//                slots.set(index: ik, .unique(Pair(k,v)))
//                return .replaced(kv.value)
//            }
//            else {
//                // Insert.
//                if config.level < maxLevelIndex {
//                    // Branch down.
//                    var x = config
//                    x.level += 1
//                    var b = PD5Bucket256(config: x)
//                    b.insertOrReplace(kv.key.hashBits, kv.key, kv.value) // Take care that we need to pass correct hash here.
//                    b.insertOrReplace(h, k, v)
//                    slots.set(index: ik, .branch(b))
//                }
//                else {
//                    // Reached at max level.
//                    // Put them into a leaf.
//                    slots.set(index: ik, .leaf([kv, Pair(k,v)]))
//                }
//                sum += 1
//                return .inserted
//            }
//        case .branch(var b):
//            let r = b.insertOrReplace(h, k, v)
//            slots.set(index: ik, .branch(b))
//            switch r {
//            case .inserted:     sum += 1
//            case .replaced(_):  break
//            }
//            return r
//        case .leaf(var a):
//            for i in a.indices {
//                if a[i].key == k {
//                    // Replace.
//                    let v1 = a[i].value
//                    a[i].value = v
//                    slots.set(index: ik, .leaf(a))
//                    return .replaced(v1)
//                }
//            }
//            // Insert.
//            a.append(Pair(k,v))
//            slots.set(index: ik, .leaf(a))
//            sum += 1
//            return .inserted
//        }
//    }
//
//    enum RemoveOrIgnoreResult {
//        case removed(V)
//        case ignored
//    }
//    @inlinable
//    @inline(__always)
//    @discardableResult
//    mutating func removeOrIgnore(_ h: UInt, _ k: K) -> RemoveOrIgnoreResult {
//        let ik = slotIndex(for: h)
//        let s = slots.get(index: ik) ?? .none
//        switch s {
//        case .none:
//            return .ignored
//        case .unique(let kv):
//            if kv.key == k {
//                slots.set(index: ik, .none)
//                sum -= 1
//                return .removed(kv.value)
//            }
//            else {
//                return .ignored
//            }
//        case .branch(var b):
//            let r = b.removeOrIgnore(h, k)
//            switch r {
//            case .removed(let v):
//                sum -= 1
//                switch b.sum {
//                case 0:
//                    slots.set(index: ik, .none)
//                case 1:
//                    slots.set(index: ik, .unique(b.ADHOC_collectOne()))
//                default:
//                    slots.set(index: ik, .branch(b))
//                }
//                return .removed(v)
//            case .ignored:
//                return .ignored
//            }
//        case .leaf(var a):
//            if let i = a.firstIndex(where: { kv in kv.key == k }) {
//                let v = a[i].value
//                sum -= 1
//                a.remove(at: i)
//                switch a.count {
//                case 0:     slots.set(index: ik, .none)
//                case 1:     slots.set(index: ik, .unique(a[0]))
//                default:    slots.set(index: ik, .leaf(a))
//                }
//                return .removed(v)
//            }
//            else {
//                return .ignored
//            }
//        }
//    }
//
//    private func ADHOC_collectOne() -> Pair {
//        precondition(sum == 1)
//        for s in slots {
//            switch s {
//            case .unique(let kv):   return kv
//            default:                break
//            }
//        }
//        fatalError()
//    }
//}
////extension PD5Bucket256: Equatable where V: Equatable {
////    static func == (_ a: PD5Bucket256, _ b: PD5Bucket256) -> Bool {
////        guard a.count == b.count else { return false }
////        for p in a.pairs {
////            guard b[p.key] == p.value else { return false }
////        }
////        for p in b.pairs {
////            guard a[p.key] == p.value else { return false }
////        }
////        return true
////    }
////}
////
