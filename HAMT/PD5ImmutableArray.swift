//
//  PD5SlotArray.swift
//  HAMT-macOS
//
//  Created by Henry on 2019/06/01.
//

import Foundation

/// An array-like collection that creates a new copied instance
/// for all mutations.
///
/// There's no code path that can potentially write to a shared
/// buffer, therefore, safe for multi-threaded read/write/copy
/// scenario.
///
/// As I suspect Swift CoW cannot guarantee isolation
/// under multi-threaded envinronment, I enfoce to copy
/// slots before every time I change it.
///
struct PD5ImmutableArray<T>: RandomAccessCollection, MutableCollection {
    private let core: ContiguousArray<T>
    /// Initialized an empty collection.
    init() {
        core = []
    }
    init(inserting e: T, at i: Int, from c: PD5ImmutableArray) {
        var a = ContiguousArray<T>()
        a.reserveCapacity(c.count + 1)
        for j in 0..<i {
            a.append(c[j])
        }
        a.append(e)
        for j in i..<c.count {
            a.append(c[j])
        }
        core = a
    }
    init(updatingAt i: Int, with e: T, from c: PD5ImmutableArray) {
        var a = ContiguousArray<T>()
        a.reserveCapacity(c.count)
        for j in 0..<i {
            a.append(c[j])
        }
        a.append(e)
        for j in (i+1)..<c.count {
            a.append(c[j])
        }
        core = a
    }
    init(removingAt i: Int, from c: PD5ImmutableArray) {
        var a = ContiguousArray<T>()
        a.reserveCapacity(c.count - 1)
        for j in 0..<i {
            a.append(c[j])
        }
        for j in (i+1)..<c.count {
            a.append(c[j])
        }
        core = a
    }

    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return core.count
    }
    subscript(_ i: Int) -> T {
        get { return read(at: i) }
        set(v) { write(v, at: i) }
    }
    private func read(at i: Int) -> T {
        return core[i]
    }
    private mutating func write(_ e: T, at i: Int) {
        self = PD5ImmutableArray(updatingAt: i, with: e, from: self)
    }

    mutating func insert(_ e: T, at i: Int) {
        self = PD5ImmutableArray(inserting: e, at: i, from: self)
    }
    mutating func remove(at i: Int) {
        self = PD5ImmutableArray(removingAt: i, from: self)
    }
}

extension PD5ImmutableArray: Equatable where T: Equatable {}
