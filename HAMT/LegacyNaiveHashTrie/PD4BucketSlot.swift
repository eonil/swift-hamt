//
//  PD4BucketSlot.swift
//  PD4
//
//  Created by Henry on 2019/05/22.
//  Copyright © 2019 Eonil. All rights reserved.
//

enum PD4BucketSlot<K,V> where K: PD4Hashable {
    typealias Bucket = PD4Bucket<K,V>
    typealias Pair = Bucket.Pair
    ///
    /// This means there's no key-vaue pair
    /// for the hash bits.
    ///
    case none
    ///
    /// Unique hash key-value node.
    ///
    /// If there's only one key-value pair for
    /// for a hash bits, it can be stored inline
    /// in slot list. This provides best
    /// performance as it does not require linear
    /// search.
    ///
    case unique(Pair)
    ///
    /// Branch node.
    ///
    /// This contains sub-bucket for hash bits
    /// at the level.
    ///
    case branch(Bucket)
    ///
    /// Leaf node. Contains hash-collided
    /// key-value pairs.
    ///
    /// This contains key-value pairs for same
    /// hash bits. This node should exist only
    /// at maximum level.
    ///
    /// Normal leafs always keep their capacity
    /// in limit. But leaf node at maximum depth
    /// can contain arbitrary elements.
    /// This is because we don't have any more
    /// hash bits, therefore having more levels
    /// meaningless.
    ///
    case leaf(Bucket.Array<Pair>)
}
