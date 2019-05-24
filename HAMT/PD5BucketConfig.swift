//
//  PD5BucketConfig.swift
//  HAMT
//
//  Created by Henry on 2019/05/23.
//

struct PD5BucketConfig: Equatable {
    /// Level of current bucket.
    /// Level 0 means root-level bucket.
    /// Maximum level for 64-bit bucket is 9.
    /// Bucket level 10 is invald.
    var level = UInt8(0)
}
