//
//  PD4Hashable.swift
//  PD4
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

///
/// Swift's standard `Hashable` implementation is not deterministic
/// and does not provide reproducibility, and can be different for
/// different executions.
///
/// I need reproducible hash value for deterministic test and
/// have to avoid Swift standard hashings. Hence I defined this
/// type.
///
/// It's unclear how I can avoid Swift standard hashing.
/// I just define this protocol to avoid them completely.
///
/// For test, you can provide some deterministic hash bits.
/// For production, it doesn't have to be deterministic or
/// reproducible over exeuctions. You can route to Swift standard
/// hashing.
///
protocol PD4Hashable: Equatable {
    var hashBits: Int { get }
}

