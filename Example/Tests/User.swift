//
//  User.swift
//  Structify_Example
//
//  Created by Artur Mkrtchyan on 2/4/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation

struct User {
    var id: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var age: Int = 0
    var avatar: String = ""
    var x: Double = 0
    var y: Int = 0
    var birthday: Date = Date()
    var location: Location = Location()
    var isAdmin: Bool = false
}
