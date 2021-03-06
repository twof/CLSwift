//
//  InputError.swift
//  osxdotool
//
//  Created by fnord on 7/5/17.
//  Copyright © 2017 twof. All rights reserved.
//

import Foundation

public enum InputError: Error {
    
    case invalidType(String)
    case argumentNotFound
    case wrongNumberOfArgs(expected: NumberOfParams, actual: Int)
    case invalidCommand
    case unimplimented
    case customError(String)
}
