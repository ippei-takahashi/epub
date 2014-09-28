//
//  NSMutableArray+QueueAdditions.h
//  Epub
//
//  Created by ポニー村山 on 2014/09/28.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end