//
//  Book.h
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, readonly) UIImageView *imageView;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
