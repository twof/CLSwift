//
//  Result.swift
//  CLSwift
//
//  Created by fnord on 9/14/17.
//
//

import Foundation

public typealias State = [String: AnyHashable]

public enum Result<T> {
    case success(T, State)
    case error(Error)
}
