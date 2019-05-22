//
//  HAMT.swift
//  SwiftHashTrie-macOS
//
//  Created by Henry on 2019/05/23.
//

import Foundation

public typealias HAMT<Key,Value> = PD5<Key,Value> where Key: Hashable
