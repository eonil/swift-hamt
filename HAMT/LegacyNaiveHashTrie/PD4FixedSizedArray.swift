//
//  PD4FixedSizedArray.swift
//  SwiftHashTrie-macOS
//
//  Created by Henry on 2019/05/22.
//

import Foundation

struct PD4FixedSizedArray<T>: RandomAccessCollection {
    private var buffer: FixedSizedBuffer<T>

    init(repeating v: T, count c: Int) {
        buffer = FixedSizedBuffer(capacity: c, default: v)
    }

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return buffer.capacity
    }

    subscript(_ i: Int) -> T {
        get { return buffer[i] }
        set(v) {
            if !isKnownUniquelyReferenced(&buffer) {
                buffer = buffer.copy()
            }
            buffer[i] = v
        }
    }
}
private final class FixedSizedBuffer<T>: RandomAccessCollection {
    let capacity: Int
    private var ptr: UnsafeMutablePointer<T>
    init(capacity c: Int, default v: T) {
        capacity = c
        ptr = UnsafeMutablePointer<T>.allocate(capacity: c)
        ptr.initialize(repeating: v, count: c)
    }
    init(copying src: FixedSizedBuffer) {
        capacity = src.capacity
        ptr = UnsafeMutablePointer<T>.allocate(capacity: src.capacity)
        ptr.initialize(from: src.ptr, count: src.capacity)
    }
    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return capacity
    }
    subscript(_ i: Int) -> T {
        get {
            return ptr[i]
        }
        set(v) {
            ptr[i] = v
        }
    }
    deinit {
        ptr.deinitialize(count: capacity)
        ptr.deallocate()
    }
    func copy() -> FixedSizedBuffer<T> {
        return FixedSizedBuffer(copying: self)
    }
}
