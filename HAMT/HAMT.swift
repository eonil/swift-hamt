//
//  HAMT.swift
//  HAMT
//
//  Created by Henry on 2019/05/23.
//

import Foundation

///
/// HAMT(Hash Array Mapped Trie, Bagwell).
///
/// `HAMT` provides near constant time (`O(10)`) performance up to
/// hash resolution limit (`(2^6)^10` items) for read/write/copy regardless of item count
/// where copying `Swift.Dictionary` takes linearly increased time.
///
/// Base read performance of `HAMT` is about 2x-50x times slower
/// than ephemeral `Swift.Dictionary`.
///
public struct HAMT<Key,Value> where Key: Hashable {
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
        }
    }
    public subscript(_ key: Key, default defaultValue: @autoclosure() -> Value) -> Value {
        get { return self[key] ?? defaultValue() }
        set(v) { self[key] = v }
    }
}

extension HAMT: Sequence {
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
        private(set) var source: HAMT
        public func makeIterator() -> Iterator {
            return Iterator(source: source.makeIterator())
        }
        public struct Iterator: IteratorProtocol {
            var source: HAMT.Iterator
            public mutating func next() -> Key? {
                return source.next()?.key
            }
        }
    }

    public var values: ValueSequence {
        return ValueSequence(source: self)
    }
    public struct ValueSequence: Sequence {
        private(set) var source: HAMT
        public func makeIterator() -> Iterator {
            return Iterator(source: source.makeIterator())
        }
        public struct Iterator: IteratorProtocol {
            var source: HAMT.Iterator
            public mutating func next() -> Value? {
                return source.next()?.value
            }
        }
    }
}

public extension HAMT {
    mutating func removeAll() {
        self = HAMT()
    }
}

/// A zero-cost wrapper to route system hash value
/// to `PD5Hashable` protocol.
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
    /// Strips off `PD5Pair` wrapper.
    var tuplized: (key: K, value: V) {
        return (key,value)
    }
}
