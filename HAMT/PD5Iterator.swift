//
//  PD5Iterator.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/23.
//

import Foundation

extension PD5Bucket64 {
//    typealias PairSequence = LazySequence<FlattenSequence<LazyMapSequence<DFSSlotSequence, Slot.CurrentLevelPairs>>>
    /// All pairs in this bucket subtree.
    var pairs: PairSequence {
        return PairSequence(source: dfsSlots.lazy.flatMap({ s in s.currentLevelPairs }))
    }
    struct PairSequence: Sequence {
        var source: LazySequence<FlattenSequence<LazyMapSequence<DFSSlotSequence, Slot.CurrentLevelPairs>>>
        func makeIterator() -> Iterator {
            return Iterator(source: source.makeIterator())
        }
        struct Iterator: IteratorProtocol {
            var source: LazySequence<FlattenSequence<LazyMapSequence<DFSSlotSequence, Slot.CurrentLevelPairs>>>.Iterator
            mutating func next() -> PD5Pair<K,V>? {
                return source.next()
            }
        }
    }
}

extension PD5Slot64 {
    var currentLevelPairs: CurrentLevelPairs {
        switch self {
        case .none:             return .none
        case .unique(let kv):   return .single(kv)
        case .branch(_):        return .none // Skip as this one should performs shallow iteration...
        case .leaf(let a):      return .multiple(a)
        }
    }
    enum CurrentLevelPairs: Sequence {
        case none
        case single(Pair)
        case multiple(ContiguousArray<Pair>)

        func makeIterator() -> Iterator {
            return Iterator(of: self)
        }
        struct Iterator: IteratorProtocol {
            private var source: CurrentLevelPairs
            private var index = 0
            init(of s: CurrentLevelPairs) {
                source = s
            }
            mutating func next() -> Pair? {
                switch source {
                case .none:
                    return nil
                case .single(let p):
                    guard index == 0 else { return nil }
                    index += 1
                    return p
                case .multiple(let ps):
                    guard index < ps.count else { return nil }
                    index += 1
                    return ps[index]
                }
            }
        }
    }
}

extension PD5Bucket64 {
    var dfsSlots: DFSSlotSequence {
        return DFSSlotSequence(of: self)
    }
    struct DFSSlotSequence: Sequence {
        private var source: PD5Bucket64
        init(of b: PD5Bucket64) {
            source = b
        }
        func makeIterator() -> DFSSlotIterator {
            return DFSSlotIterator(of: source)
        }
    }
    struct DFSSlotIterator: IteratorProtocol {
        private var stack = [PD5CompressedTable64<Slot>.Iterator]()
        init(of b: PD5Bucket64) {
            stack.append(b.slots.makeIterator())
        }
        mutating func next() -> Slot? {
            while var previewit = stack.last {
                if let s = previewit.next() {
                    switch s {
                    case .branch(let b):
                        let it1 = b.slots.makeIterator()
                        stack[stack.count - 1] = previewit // Write back.
                        stack.append(it1) // Stack up.
                        return s
                    default:
                        stack[stack.count - 1] = previewit // Write back.
                        return s
                    }
                }
                else {
                    stack.removeLast()
                }
            }
            return nil
        }
    }
}

extension PD5Bucket64.DFSSlotSequence: Equatable where V: Equatable {}
extension PD5Slot64.CurrentLevelPairs: Equatable where V: Equatable {}
