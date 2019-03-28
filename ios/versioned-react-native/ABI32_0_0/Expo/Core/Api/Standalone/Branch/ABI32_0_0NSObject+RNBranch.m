//
//  NSObject+RNBranch.m
//  ABI32_0_0RNBranch
//
//  Created by Jimmy Dee on 1/26/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//

#import <ReactABI32_0_0/ABI32_0_0RCTLog.h>

#import "ABI32_0_0NSObject+RNBranch.h"
#import "ABI32_0_0RNBranchProperty.h"

@implementation NSObject(ABI32_0_0RNBranch)

+ (NSDictionary<NSString *,ABI32_0_0RNBranchProperty *> *)supportedProperties
{
    return @{};
}

- (void)setSupportedPropertiesWithMap:(NSDictionary *)map
{
    for (NSString *key in map.allKeys) {
        ABI32_0_0RNBranchProperty *property = self.class.supportedProperties[key];
        if (!property) {
            ABI32_0_0RCTLogWarn(@"\"%@\" is not a supported property for %@.", key, NSStringFromClass(self.class));
            continue;
        }
        
        id value = map[key];
        Class type = property.type;
        if (![value isKindOfClass:type]) {
            ABI32_0_0RCTLogWarn(@"\"%@\" requires a value of type %@.", key, NSStringFromClass(type));
            continue;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:property.setterSelector withObject:value];
#pragma clang diagnostic pop
    }
}

@end
