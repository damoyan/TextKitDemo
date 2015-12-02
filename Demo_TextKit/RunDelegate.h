//
//  RunDelegate.h
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/1/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

extern NSMutableAttributedString* generateRunDelegate(NSMutableAttributedString *attriString, UIImage *image, UIFont *font, NSRange range);

@interface RunDelegate : NSObject<NSCopying, NSCoding>

@property (nonatomic, assign) CGFloat ascent;
@property (nonatomic, assign) CGFloat descent;
@property (nonatomic, assign) CGFloat width;

- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;

@end
