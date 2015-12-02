//
//  RunDelegate.m
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/1/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

#import "RunDelegate.h"

NSMutableAttributedString* generateRunDelegate(NSMutableAttributedString *attriString, UIImage *image, UIFont *font, NSRange range) {
    RunDelegate *delegate = [RunDelegate new];
    delegate.ascent = image.size.height + font.descender;
    if (delegate.ascent < 0) {
        delegate.ascent = 0;
    }
    delegate.descent = font.descender;
    delegate.width = image.size.width;
    [attriString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate.CTRunDelegate range:range];
    return attriString;
}



static void DeallocCallback(void *ref) {
    RunDelegate *delegate = (__bridge_transfer RunDelegate *)ref;
    delegate = nil;
}

static CGFloat GetAscentCallback(void *ref) {
    RunDelegate *delegate = (__bridge RunDelegate *)ref;
    return delegate.ascent;
}

static CGFloat GetDescentCallback(void *ref) {
    RunDelegate *delegate = (__bridge RunDelegate *)ref;
    printf("%f", delegate.descent);
    return delegate.descent;
}

static CGFloat GetWidthCallback(void *ref) {
    RunDelegate *delegate = (__bridge RunDelegate *)ref;
    return delegate.width;
}

@implementation RunDelegate


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _ascent = ((NSNumber *)[aDecoder decodeObjectForKey:@"ascent"]).floatValue;
        _descent = ((NSNumber *)[aDecoder decodeObjectForKey:@"descent"]).floatValue;
        _width = ((NSNumber *)[aDecoder decodeObjectForKey:@"width"]).floatValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.ascent) forKey:@"ascent"];
    [aCoder encodeObject:@(self.descent) forKey:@"descent"];
    [aCoder encodeObject:@(self.width) forKey:@"width"];
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.width = self.width;
    return one;
}

- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED {
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = DeallocCallback;
    callbacks.getAscent = GetAscentCallback;
    callbacks.getDescent = GetDescentCallback;
    callbacks.getWidth = GetWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(self.copy));
}

@end
