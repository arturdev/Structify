//
//  Structify.swift
//  StrVsObj
//
//  Created by Artur Mkrtchyan on 1/31/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import Reflection
#if canImport(RealmSwift)
import RealmSwift
import Realm
#endif

public protocol SelfAware: class {
    static func awake()
}

@objc open class Structify: NSObject {
    @objc public static func go() {
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
            let label = $0.label!
            let value = $0.value
            if value is ObjectConvertibleBase {
                guard let className = propertyClassName(label, objectType) else {return}
                let fullClassName = classNames.first(where: {$0.contains(className)}) ?? className
                guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
                let o = convert(val: value, to: c)
                if obj.responds(to: NSSelectorFromString(label)) {
                    obj.setValue(o, forKey: label)
                }
            } else {
                if obj.responds(to: NSSelectorFromString(label)) {
                    if let values = value as? [Any] {
                        #if canImport(RealmSwift)
                             let realmArray = obj.value(forKey: label) as? RLMArray<AnyObject>
                             values.forEach({value in
                                if value is ObjectConvertibleBase {
                                    guard let className = realmArray?.objectClassName else {return}
                                    let fullClassName = classNames.first(where: {$0.contains(className)}) ?? className
                                    guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
                                    let o = convert(val: value, to: c)
                                    realmArray?.add(o)
                                } else {
                                    realmArray?.add(value as AnyObject)
                                }
                             })
                        #else
                            obj.setValue(value, forKey: label)
                        #endif
                    } else {
                        obj.setValue(value, forKey: label)
                    }
                }
            }
        })
        return obj        
    }

    private override init() {}
    fileprivate static var classNames: [String] = []
}

public protocol ObjectConvertibleBase {
    func getType() -> String
    func objectType() -> StructConvertibleBase.Type
    init()
    mutating func readValues(from object: StructConvertibleBase)
    static func ignoredProperties() -> [String]
    
}

public extension ObjectConvertibleBase {
    public static func ignoredProperties() -> [String] {
        return []
    }
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
    
    func objectType() -> StructConvertibleBase.Type {
        return ClassType.self
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
                    if value is NSFastEnumeration {
                        #if canImport(RealmSwift)
                            var selfArray: [Any] = (try? get(propertyName, from: self)) ?? []
                            let realmArray = value as! RLMArray<AnyObject>
                            for i in 0..<realmArray.count {
                                let o = realmArray[i]
                                if let sc = o as? StructConvertibleBase {
                                    var scVal = sc.structType().init()
                                    scVal.readValues(from: sc)
                                    selfArray.append(scVal)
                                    print(sc)
                                } else {
                                    selfArray.append(o)
                                }
                                
                            }
                            try set(selfArray, key: propertyName, for: &self)
                        #else
                            try set(value, key: propertyName, for: &self)
                        #endif
                    } else {
                        try set(value, key: propertyName, for: &self)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

public protocol StructConvertibleBase: SelfAware {
    func structType() -> ObjectConvertibleBase.Type
}

public protocol StructConvertible: StructConvertibleBase {
    associatedtype StructType: ObjectConvertible
}

public extension StructConvertible where Self: NSObject {
    static func awake() {
        let obj = StructType()
        mirrorProperties(of: obj, to: self, ignoreProperties: StructType.ignoredProperties())
    }
    
    public func toStruct() -> StructType {
        var val = StructType()
        val.readValues(from: self)
        return val
    }
    
    func structType() -> ObjectConvertibleBase.Type {
        return StructType.self
    }
}

