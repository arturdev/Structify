//
//  DynamicMethods.h
//  StrVsObj
//
//  Created by Artur Mkrtchyan on 1/31/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

#import <Foundation/Foundation.h>

void addPropertyToClass(Class className, NSString *name, NSString *typeName);
NSString * __nullable propertyClassName(NSString *name, Class className);
