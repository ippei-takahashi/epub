//
//  Book.h
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, readwrite) NSString *fileName;
@property (nonatomic, readwrite) UIImageView *imageView;
@property (readwrite) double progress;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
