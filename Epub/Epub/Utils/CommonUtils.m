//
//  CommonUtils.m
//  GIFMAGAZINE
//
//  Created by ポニー村山 on 2014/04/20.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

UIFont *fontVerySmall;
UIFont *fontSmall;
UIFont *fontMedium;
UIFont *fontLarge;
UIFont *fontTitle;

UIColor *colorTheme;
UIColor *colorBackground;
UIColor *colorFont;
UIColor *colorFontDark;

+ (UIFont *)fontVerySmall
{
    if (!fontVerySmall) {
        fontVerySmall = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    }
    return fontVerySmall;
}


+ (UIFont *)fontSmall
{
    if (!fontSmall) {
        fontSmall = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    }
    return fontSmall;
}

+ (UIFont *)fontMedium
{
    if (!fontMedium) {
        fontMedium = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
    }
    return fontMedium;
}

+ (UIFont *)fontLarge
{
    if (!fontLarge) {
        fontLarge = [UIFont fontWithName:@"HiraKakuProN-W3" size:22];
    }
    return fontLarge;
}

+ (UIFont *)fontTitle
{
    if (!fontTitle) {
        fontTitle = [UIFont fontWithName:@"GeosansLight" size:26];
    }
    return fontTitle;
}


+ (UIColor *)colorTheme
{
    if (!colorTheme) {
        colorTheme = [UIColor colorWithRed:0.976 green:0.494 blue:0.463 alpha:1.0];
    }
    return colorTheme;
}

+ (UIColor *)colorBackground
{
    if (!colorBackground) {
        colorBackground = [UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1.0];
    }
    return colorBackground;
}

+ (UIColor *)colorFont
{
    if (!colorFont) {
        colorFont = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.0];
    }
    return colorFont;
}

+ (UIColor *)colorFontDark
{
    if (!colorFontDark) {
        colorFontDark = [UIColor colorWithRed:0.412 green:0.412 blue:0.412 alpha:1.0];
    }
    return colorFontDark;
}

+ (UIImageView *)statusBarView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = [CommonUtils makeNormalizeRect:0 top:0 width:[APP BASE_WIDTH] height:[CommonUtils unnormalizeHeight:[APP STATUS_BAR_HEIGHT]]];
    imageView.backgroundColor = [UIColor blackColor];
    return imageView;
}

+ (UINavigationItem *)title
{
    UINavigationItem *title = [[UINavigationItem alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"ライブラリ";
    label.font = [CommonUtils fontTitle];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    title.titleView = label;
    return title;
}


+ (UINavigationItem *)title:(NSString *)text
{
    UINavigationItem *title = [[UINavigationItem alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [CommonUtils fontTitle];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    title.titleView = label;
    return title;
}

+ (UINavigationBar *)navBar
{
    UINavigationItem *title = [self title];
    return [self navBar:title];
}

+ (UINavigationBar *)navBar:(UINavigationItem *)title
{
    return nil;
}

+ (id)getValueWithName:(NSString *)name fromDictionary:(NSDictionary *)dic
{
    id data = [dic objectForKey:@"data"];
    if (data && [data respondsToSelector:@selector(objectForKey:)]) {
        return [data objectForKey:name];
    } else if ([data respondsToSelector:@selector(objectAtIndex:)] && [data count] > 0) {
        data = [data objectAtIndex:0];
        if (data && [data respondsToSelector:@selector(objectForKey:)]) {
            return [data objectForKey:name];
        }
    }
    return nil;
}


+ (CGRect)makeNormalizeRect:(float)left top:(float)top width:(float)width height:(float)height
{
    return CGRectMake((left / [APP BASE_WIDTH]) * [APP WINDOW_WIDTH],
                      (top / [APP BASE_HEIGHT]) * [APP WINDOW_HEIGHT],
                      (width / [APP BASE_WIDTH]) * [APP WINDOW_WIDTH],
                      (height / [APP BASE_HEIGHT]) * [APP WINDOW_HEIGHT]);
}

+ (float)unnormalizeHeight:(float)height
{
    return height * [APP BASE_HEIGHT] / [APP WINDOW_HEIGHT];
}

+ (float)unnormalizeWidth:(float)width
{
    return width * [APP BASE_WIDTH] / [APP WINDOW_WIDTH];
}

+ (BOOL)isGuest:(NSString *)userId
{
    if (userId == nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"10364" forKey:@"user_id"];
        [ud setObject:@"email_c370f7b5-a077-4793-ad47-bd385d3cd405" forKey:@"user_key"];
        [ud synchronize];
        return YES;
    }
    
    if ([userId isEqual:@"10364"]) {
        return YES;
    } else {
        return NO;
    }
    
    return YES;
}

@end
