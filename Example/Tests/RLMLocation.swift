//
//  RLMLocation.swift
//  Structify_Tests
//
//  Created by Artur Mkrtchyan on 2/4/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import Structify

class RLMLocation: Object {
    
}

extension RLMLocation: StructConvertible {
    typealias StructType = Location
}

extension Location: ObjectConvertible {
    typealias ClassType = RLMLocation
}
