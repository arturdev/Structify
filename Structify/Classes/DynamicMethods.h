//
//  DynamicMethods.h
//  StrVsObj
//
//  Created by Artur Mkrtchyan on 1/31/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

#import <Foundation/Foundation.h>

void addPropertyToClass(Class _Nullable className, NSString * _Nullable name, NSString * _Nullable typeName);
NSString * __nullable propertyClassName(NSString * _Nullable name, Class _Nullable className);
