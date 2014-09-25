//
//  BookRepository.h
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface BookRepository : NSObject

@property (nonatomic, readonly) NSMutableArray *books;

- (void)addBook:(Book *)book;
- (void)removeBook:(Book *)book;

- (void)moveBookAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)replaceBookAtIndex:(NSUInteger)index withBook:(Book *)book;

- (NSArray *)loadBookNames;

@end
