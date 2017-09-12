//
//  Int+CustomStringConvertable.swift
//  CLSwift
//
//  Created by fnord on 8/20/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

extension Int: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let val = Int.init(description, radix: 10) else {return nil}
        
        self = val
    }
}
