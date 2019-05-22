//
//  FormattingUtility.swift
//  PD4PerfTool
//
//  Created by Henry on 2019/05/22.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

extension Int {
    var metricPrefixed: String {
        let s = 1000
        var a = self
        if a < s { return "\(a)" }
        a /= s
        if a < s { return "\(a)k" }
        a /= s
        if a < s { return "\(a)M" }
        a /= s
        if a < s { return "\(a)G" }
        a /= s
        if a < s { return "\(a)T" }
        a /= s
        if a < s { return "\(a)P" }
        a /= s
        if a < s { return "\(a)E" }
        a /= s
        if a < s { return "\(a)Z" }
        a /= s
        return "\(a)Y"
    }
    func percent(in denominator: Int) -> String {
        let a = Double(self) / Double(denominator) * 100
        return "\(Int(a))%"
    }
    func metricPrefixedNanoSeconds() -> String {
        let s = 1000
        var a = self
        if a < s { return "\(a)ns" }
        a /= s
        if a < s { return "\(a)μs" }
        a /= s
        if a < s { return "\(a)ms" }
        a /= s
        return "\(a)s"
    }
}
