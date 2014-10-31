//
//  AppDelegate.h
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) CGFloat BASE_WIDTH;
@property (nonatomic, readonly) CGFloat BASE_HEIGHT;
@property (nonatomic, readonly) CGFloat WINDOW_WIDTH;
@property (nonatomic, readonly) CGFloat WINDOW_HEIGHT;
@property (nonatomic, readonly) CGFloat STATUS_BAR_HEIGHT;
@property (nonatomic, readonly) CGRect BOUNDS_RECT;

@property (nonatomic, readwrite) Book *downloadingBook;
@property (nonatomic, readwrite) NSMutableArray *downloadingBookQueue;

@end
