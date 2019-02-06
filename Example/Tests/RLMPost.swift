//
//  RLMPost.swift
//  Structify_Tests
//
//  Created by Artur Mkrtchyan on 2/4/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import Structify

class RLMPost: Object {
    @objc dynamic var likes: RLMArray<RLMUser> = RLMArray(objectClassName: "RLMUser")
    @objc open override class func primaryKey() -> String? {
        return "id"
    }
}

extension RLMPost: StructConvertible {
    typealias StructType = Post
}

extension Post: ObjectConvertible {
    typealias ClassType = RLMPost
}
