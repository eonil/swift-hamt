////
////  PD5CompressedTable256.swift
////  SwiftHashTrie-macOS
////
////  Created by Henry on 2019/05/23.
////
//
//struct PD5CompressedTable256<T>: Sequence {
//    typealias Element = T
//    typealias Table = PD5CompressedTable64<T>
//    private var t0 = Table()
//    private var t1 = Table()
//    private var t2 = Table()
//    private var t3 = Table()
//
//    private var bitmap = UInt64(0b0)
//    private var slots = ContiguousArray<T>()
//
//    @inlinable
//    @inline(__always)
//    var capacity: Int {
//        return 256
//    }
//    @inlinable
//    @inline(__always)
//    var count: Int {
//        return t0.count + t1.count + t2.count + t3.count
//    }
//    
//    typealias Iterator = FlattenSequence<LazyMapSequence<[PD5CompressedTable64<T>], PD5CompressedTable64<T>>>.Iterator
//    @inlinable
//    @inline(__always)
//    func makeIterator() -> Iterator {
//        let s = [t0,t1,t2,t3].lazy.flatMap({ $0 })
//        let it = s.makeIterator()
//        return it
//    }
//
//    /// Incoming index-key is ending 8bit of hash bits. (0~255 range)
//    @inlinable
//    @inline(__always)
//    func get(index k: UInt) -> T? {
//        let m1 = 0b0_1100_0000 as UInt
//        let m2 = 0b0_0011_1111 as UInt
//        let a = k & m1 >> 6
//        let b = k & m2
//        switch a {
//        case 0:     return t0.get1(index: b)
//        case 1:     return t1.get1(index: b)
//        case 2:     return t2.get1(index: b)
//        case 3:     return t3.get1(index: b)
//        default:    fatalError("Bad index-key bits.")
//        }
////        switch k {
////        case 0..<64:    return t0.get(index: k - 0, default: defv())
////        case 64..<128:  return t1.get(index: k - 64, default: defv())
////        case 128..<192: return t2.get(index: k - 128, default: defv())
////        case 192..<256: return t3.get(index: k - 192, default: defv())
////        default:        fatalError("Bad index-key bits.")
////        }
//    }
//    @inlinable
//    @inline(__always)
//    mutating func set(index k: UInt, _ v: T) {
////        switch k {
////        case 0..<64:    t0.set(index: k - 0, v)
////        case 64..<128:  t1.set(index: k - 64, v)
////        case 128..<192: t2.set(index: k - 128, v)
////        case 192..<256: t3.set(index: k - 192, v)
////        default:        fatalError("Bad index-key bits.")
////        }
//        let m1 = 0b0_1100_0000 as UInt
//        let m2 = 0b0_0011_1111 as UInt
//        let a = k & m1 >> 6
//        let b = k & m2
//        switch a {
//        case 0:     t0.set(index: b, v)
//        case 1:     t1.set(index: b, v)
//        case 2:     t2.set(index: b, v)
//        case 3:     t3.set(index: b, v)
//        default:    fatalError("Bad index-key bits.")
//        }
//    }
//    @inlinable
//    @inline(__always)
//    mutating func unset(index k: UInt) {
////        switch k {
////        case 0..<64:    t0.unset(index: k - 0)
////        case 64..<128:  t1.unset(index: k - 64)
////        case 128..<192: t2.unset(index: k - 128)
////        case 192..<256: t3.unset(index: k - 192)
////        default:        fatalError("Bad index-key bits.")
////        }
//        let m1 = 0b0_1100_0000 as UInt
//        let m2 = 0b0_0011_1111 as UInt
//        let a = k & m1 >> 6
//        let b = k & m2
//        switch a {
//        case 0:     t0.unset(index: b)
//        case 1:     t1.unset(index: b)
//        case 2:     t2.unset(index: b)
//        case 3:     t3.unset(index: b)
//        default:    fatalError("Bad index-key bits.")
//        }
//    }
//}
//extension PD5CompressedTable256: Equatable where T: Equatable {}
