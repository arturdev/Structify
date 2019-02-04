//
//  Structify.swift
//  StrVsObj
//
//  Created by Artur Mkrtchyan on 1/31/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import Reflection

public protocol SelfAware: class {
    static func awake()
}

open class Structify {
    public static func go() {
        if !classNames.isEmpty {
            return
        }
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let safeTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(safeTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            if let C = (types[index] as? SelfAware.Type) {
                C.awake()
                classNames.append(NSStringFromClass(C))
            }
        }
        types.deallocate()
    }
    
    static func convert<T: NSObject>(val: Any, to objectType: T.Type) -> AnyObject {
        let mirror = Mirror(reflecting: val)
        let children = mirror.children
        let obj = objectType.init()
        children.filter({$0.label != nil}).forEach({
            if $0.value is ObjectConvertibleBase {
                guard let className = propertyClassName($0.label!, objectType) else {return}
                let fullClassName = classNames.first(where: {$0.contains(className)}) ?? className
                guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
                let o = convert(val: $0.value, to: c)
                if obj.responds(to: NSSelectorFromString($0.label!)) {
                    obj.setValue(o, forKey: $0.label!)
                }
            } else {
                if obj.responds(to: NSSelectorFromString($0.label!)) {
                    obj.setValue($0.value, forKey: $0.label!)
                }
            }
        })
        return obj
    }
    
    
    private init() {}
    fileprivate static var classNames: [String] = []
}

public protocol ObjectConvertibleBase {
    func getType() -> String
    init()
    mutating func readValues(from object: StructConvertibleBase)
}

public protocol ObjectConvertible:ObjectConvertibleBase {
    associatedtype ClassType: NSObject, StructConvertible
}

public extension ObjectConvertible {
    public func toObject() -> ClassType {
        let obj = Structify.convert(val: self, to: ClassType.self) as! ClassType //ClassType()
        return obj
    }
    
    func getType() -> String {
        return String(describing: ClassType.self)
    }
    
    mutating func readValues(from object: StructConvertibleBase) {
        let obj = object as! NSObject
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        for child in children {
            guard let propertyName = child.label else {continue}
            guard obj.responds(to: NSSelectorFromString(propertyName)) else {continue}
            guard let value = obj.value(forKey: propertyName) else {continue}
            if let value = value as? StructConvertibleBase {
                var childValue = child.value as? ObjectConvertibleBase
                if childValue == nil {
                    childValue = (type(of: child.value) as! ObjectConvertibleBase.Type).init()
                }
                
                childValue!.readValues(from: value)
                do {
                    try set(childValue!, key: propertyName, for: &self)
                }
                catch {
                    print(error)
                }
            } else {
                do {
                    try set(value, key: propertyName, for: &self)
                }
                catch {
                    print(error)
                }
            }
        }
        
    }
}

public protocol StructConvertibleBase: SelfAware {
    
}

public protocol StructConvertible: StructConvertibleBase {
    associatedtype StructType: ObjectConvertible
}

public extension StructConvertible where Self: NSObject {
    static func awake() {
        let obj = StructType()
        mirrorProperties(of: obj, to: self)
    }
    
    public func toStruct() -> StructType {
        var val = StructType()
        val.readValues(from: self)
        return val
    }
}
