//
//  PD5Hashable.swift
//  PD5UnitTests
//
//  Created by Henry on 2019/05/23.
//

import Foundation

///
/// Every state has to be reproducible to write precise stable test code.
///
/// Swift's system default `Hashable.hashValue` implementation does not
/// guarantee reproduction of same value for same input on different
/// sessions, therefore should be avoided.
///
/// Instead of directly using `Hashable`, I defined another route to
/// get hash value. With this type, I can guarantee certain hash values,
/// and can observe & test state change for specific hash values.
///
protocol PD5Hashable: Equatable {
    ///
    /// Provides custom hash values.
    ///
    /// For user's production code, it is recommended using
    /// Swift's default `hashValue` implementation.
    ///
    /// For test code, you can return specific value that fits
    /// to your test needs.
    ///
    @inlinable
    var hashBits: UInt { get }
}
