//
//  PD5Pair.swift
//  HAMT
//
//  Created by Henry on 2019/05/23.
//

/// Simpler explicit composition of key and value
/// to provide explicit protocol conformation.
struct PD5Pair<K,V> {
    var key: K
    var value: V
    
    @inlinable
    init(_ k: K, _ v: V) {
        key = k
        value = v
    }
}

extension PD5Pair: Equatable where K: Equatable, V: Equatable {}
