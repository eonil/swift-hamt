//
//  PD5.swift
//  SwiftHashTrie-macOS
//
//  Created by Henry on 2019/05/23.
//

import Foundation

///
/// Persistent Dictionary v5.
///
public struct PD5<Key,Value> where Key: Hashable {
    private var root = PD5Bucket64<PD5Key<Key>,Value>()
    private var sum = 0

    @inlinable
    public init() {}

    public var isEmpty: Bool {
        return root.count == 0
    }

    public var count: Int {
        return sum
    }

    public subscript(_ key: Key) -> Value? {
        get {
            let k1 = PD5Key(key)
            return root[k1]
        }
        set(v) {
            let k1 = PD5Key(key)
            if let v = v {
                switch root.insertOrReplace(k1.hashBits, k1, v) {
                case .inserted: sum += 1
                case .replaced: break
                }
            }
            else {
                switch root.removeOrIgnore(k1.hashBits, k1) {
                case .removed:  sum -= 1
                case .ignored:  break
                }
            }
//            root[k1] = v
        }
    }
    public subscript(_ key: Key, default defaultValue: @autoclosure() -> Value) -> Value {
        get { return self[key] ?? defaultValue() }
        set(v) { self[key] = v }
    }
}
extension PD5: Sequence {
    public func makeIterator() -> Iterator {
        let it = root.pairs.makeIterator()
        return Iterator(source: it)
    }
    public struct Iterator: IteratorProtocol {
        fileprivate private(set) var source: PD5Bucket64<PD5Key<Key>,Value>.PairSequence.Iterator
        public mutating func next() -> (key: Key, value: Value)? {
            guard let n = source.next() else { return nil }
            return (n.key.source,n.value)
        }
    }
    public var keys: KeySequence {
        return KeySequence(source: self)
    }
    public struct KeySequence: Sequence {
        private(set) var source: PD5
        public func makeIterator() -> Iterator {
            return Iterator(source: source.makeIterator())
        }
        public struct Iterator: IteratorProtocol {
            var source: PD5.Iterator
            public mutating func next() -> Key? {
                return source.next()?.key
            }
        }
    }

    public var values: ValueSequence {
        return ValueSequence(source: self)
    }
    public struct ValueSequence: Sequence {
        private(set) var source: PD5
        public func makeIterator() -> Iterator {
            return Iterator(source: source.makeIterator())
        }
        public struct Iterator: IteratorProtocol {
            var source: PD5.Iterator
            public mutating func next() -> Value? {
                return source.next()?.value
            }
        }
    }
}

private struct PD5Key<K>: PD5Hashable where K: Hashable {
    let source: K

    init(_ k: K) {
        source = k
    }
    var hashBits: UInt {
        return UInt(bitPattern: source.hashValue)
    }
}

private extension PD5Pair {
    var tuplized: (key: K, value: V) {
        return (key,value)
    }
}
