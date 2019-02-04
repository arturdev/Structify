//
//  SwiftRunTime.swift
//  StrVsObj
//
//  Created by Artur Mkrtchyan on 2/1/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation

func mirrorProperties(of value: Any, to className: AnyObject.Type) {
    let mirror = Mirror(reflecting: value)
    let children = mirror.children.reversed()
    
    for child in children {
        guard let name = child.label else {continue}
        let typeStr: String
        if let base = child.value as? ObjectConvertibleBase {
            typeStr = base.getType()            
        } else {
            typeStr = getTypeString(from: child.value)
        }
        addPropertyToClassIfNeeded(className: className, name: name, typeStr: typeStr)
    }
}

func addPropertyToClassIfNeeded(className: AnyObject.Type, name: String, typeStr: String) {    
    var numberObProperties: UInt32 = 0
    if let list = class_copyPropertyList(className, &numberObProperties) {
        for i in 0..<Int(numberObProperties) {
            let property = list[i]
            let propertyName = NSString(utf8String: property_getName(property)) ?? ""
            if (propertyName as String) == name {
                //Already exists
                return
            }
        }
    }
    
    addPropertyToClass(className, name, typeStr)
}

func getTypeString(from value: Any) -> String {
    if (value is Int) || (value is CShort) || (value is CLong) || (value is CLongLong) {
        return "q"
    } else if (value is Float) {
        return "f"
    } else if (value is Double) {
        return "d"
    } else if (value is Bool) {
        return "B"
    } else if (value is String) {
        return "NSString"
    } else if (value is Data) {
        return "NSData"
    } else if (value is Date) {
        return "NSDate"
    }
    
    //TODO: add nested support!
    return String(describing: type(of: value))
}
