//
//  CommonUtils.h
//  GIFMAGAZINE
//
//  Created by ポニー村山 on 2014/04/20.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface CommonUtils : NSObject

+ (UIFont *)fontVerySmall;
+ (UIFont *)fontSmall;
+ (UIFont *)fontMedium;
+ (UIFont *)fontLarge;
+ (UIFont *)fontTitle;

+ (UIColor *)colorTheme;
+ (UIColor *)colorBackground;
+ (UIColor *)colorFont;
+ (UIColor *)colorFontDark;

+ (id)getValueWithName:(NSString *)name fromDictionary:(NSDictionary *)dic;

+ (CGRect)makeNormalizeRect:(float)left top:(float)top width:(float)width height:(float)height;
+ (float)unnormalizeHeight:(float)height;
+ (float)unnormalizeWidth:(float)width;

+ (UIImageView *)statusBarView;
+ (UINavigationItem *)title;
+ (UINavigationItem *)title:(NSString *)text;
+ (UINavigationBar *)navBar;
+ (UINavigationBar *)navBar:(UINavigationItem *)title;

+ (BOOL)isGuest:(NSString *)userId;

@end
