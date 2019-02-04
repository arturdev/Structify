//
//  RLMUser.swift
//  Structify_Example
//
//  Created by Artur Mkrtchyan on 2/4/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import RealmSwift
import Structify

class RLMUser: Object {
    @objc open override class func primaryKey() -> String? {
        return "id"
    }
}

extension RLMUser: StructConvertible {
    typealias StructType = User
}

extension User: ObjectConvertible {
    typealias ClassType = RLMUser
}
