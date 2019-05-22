////
////  PD5Slot256.swift
////  PD5UnitTests
////
////  Created by Henry on 2019/05/23.
////
//
//import Foundation
//
///// Intended to be `indirect` to make slot
///// size small & regular as machine word size.
//enum PD5Slot256<K,V> where K: PD5Hashable {
//    typealias Bucket = PD5Bucket256<K,V>
//    typealias Pair = PD5Pair<K,V>
//    case none
//    case unique(Pair)
//    case branch(Bucket)
//    /// - Note:
//    ///     This needs double indirect jump.
//    ///     As leaf node is for hash-collided
//    ///     keys, I afford slowness here
//    ///     for better performance of non-collided
//    ///     keys.
//    case leaf(ContiguousArray<Pair>)
//}
//
////extension PD5Slot256: Equatable where V: Equatable {
////    static func == (_ a: PD5Slot256, _ b: PD5Slot256) -> Bool {
////        switch (a, b) {
////        case (.none, .none):                        return true
////        case (.unique(let a1), .unique(let b1)):    return a1 == b1
////        case (.branch(let a1), .branch(let b1)):    return a1 == b1
////        case (.leaf(let a1), .leaf(let b1)):        return a1 == b1
////        default:                                    return false
////        }
////    }
////}
////
