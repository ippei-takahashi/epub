//
//  Book.m
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "Book.h"

@implementation Book

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _imageView = dictionary[@"imageView"];
    }
    return self;
}


@end
