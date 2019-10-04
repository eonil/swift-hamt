//
//  File.swift
//  
//
//  Created by Henry Hathaway on 10/4/19.
//

import Foundation
import HAMT

func preconditionEqual<T:Equatable>(_ a:T, _ b:T) {
    precondition(a == b)
}

func == <K,V>(_ a: HAMT<K,V>, _ b: [K:V]) -> Bool where K: Hashable, V: Equatable {
    for k in a.keys {
        guard b[k] == a[k] else { return false }
    }
    for k in b.keys {
        guard a[k] == b[k] else { return false }
    }
    return true
}
