//
//  PD5Bucket.swift
//  HAMT
//
//  Created by Henry on 2019/05/23.
//

import Foundation

protocol PD5BucketProtocol {
    associatedtype Slot
    associatedtype Pair
    associatedtype SlotCollection: Sequence where SlotCollection.Element == Slot
    var config: PD5BucketConfig { get }
    /// Total count of all elements in this subtree.
    var slots: SlotCollection { get }
    var count: Int { get }

}
