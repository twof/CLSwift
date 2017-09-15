//
//  Result.swift
//  CLSwift
//
//  Created by fnord on 9/14/17.
//
//

import Foundation

public enum Result<T> {
    case success(T)
    case error(Error)
}
