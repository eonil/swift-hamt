//
//  Int.pd4.swift
//  PD4UnitTests
//
//  Created by Henry on 2019/05/21.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
@testable import SwiftHashTrie

extension Int: PD4Hashable {
    public var hashBits: Int {
        return self
    }
}
