//
//  Result.swift
//  CLSwift
//
//  Created by fnord on 9/14/17.
//
//

import Foundation

protocol StateProtocol {
    // changed should not be publicly accessible
    // it has great chance to ruin the internals of the framework
    var changed: Bool {get set}
}

public class StateType: StateProtocol {
    var changed: Bool = false
}
