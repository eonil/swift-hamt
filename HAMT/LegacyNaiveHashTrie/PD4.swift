//
//  PD4.swift
//  PD4
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

///
/// An implementation of *hash-trie*.
///
/// This an associative array optimized for persistent data
/// structure. Therefore, read/write/copy performances are
/// all important.
///
/// Internally this uses *hash-trie* structure. Which is somewhat
/// like B-Tree except keys are `Hashable`s rather than `Comparable`.
/// Also as this library is based on hash function, this shows
/// similar performance characteristic with hash-table.
/// For single read/write/copy this takes O(1) at best, and O(n)
/// at worst with regarding O(word size) and O(bucket size) as
/// O(1).
/// If you need sorted associative array or even more predictable
/// & stable performance characteristics, check out B-Tree
/// instead of.
///
/// - SeeAlso:
///     [BTree by Károly Lőrentey](https://github.com/attaswift/BTree)
///
/// - Complexity:
///     Get at best:   O(1) if no hashes collide with regarding O(word size) as O(1).
///     Get at worst:  O(n) if all hashes collide.
///
///     Performance is up to size of dataset and distribution of hash function.
///
///     If your dataset is small enough and hash function is well distributed,
///     it'll show O(1) performance in average. Default hash algorithm of Swift
///     standard library work well.
///
public struct PD4<K,V> where K: Hashable {
    private var b = PD4Bucket<PD4Key<K>,V>.topLevel16384Bytes()

    public init() {}
    public var count: Int {
        return b.count
    }
    public subscript(_ k: K) -> V? {
        get { return b.get(PD4Key(source: k)) }
        set(v) { b.set(PD4Key(source: k),v) }
    }
}

private struct PD4Key<K>: PD4Hashable where K: Hashable {
    let source: K
    var hashBits: Int {
        return source.hashValue
    }
}

