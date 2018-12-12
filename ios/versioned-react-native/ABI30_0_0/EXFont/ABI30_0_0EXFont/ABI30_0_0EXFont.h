// Copyright 2015-present 650 Industries. All rights reserved.

#import <Foundation/Foundation.h>

static const char *ABI30_0_0EXFontAssocKey = "ABI30_0_0EXFont";

@interface ABI30_0_0EXFont : NSObject

- (instancetype)initWithCGFont:(CGFontRef)cgFont;
- (UIFont *)UIFontWithSize:(CGFloat)fsize;

@end
