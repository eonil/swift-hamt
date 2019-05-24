//
//  PD5Pair.swift
//  SwiftHashTrie-macOS
//
//  Created by Henry on 2019/05/23.
//

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
