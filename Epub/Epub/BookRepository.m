//
//  BookRepository.m
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "BookRepository.h"

@interface BookRepository ()

@property (nonatomic, readwrite) NSMutableArray *books;

@end


@implementation BookRepository

- (instancetype) init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _books = [NSMutableArray array];
    }
    return self;
}

- (void)addBook:(Book *)book
{
    [self.books addObject:book];
}

- (void)removeBook:(Book *)book
{
    [self.books removeObject:book];
}

- (void)moveBookAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSArray *beforeSortedBooks = self.books;
    NSMutableArray *afterSortedBooks = beforeSortedBooks.mutableCopy;
    
    Book *fromBook = afterSortedBooks[fromIndex];
    [afterSortedBooks removeObjectAtIndex:fromIndex];
    [afterSortedBooks insertObject:fromBook
                             atIndex:toIndex];
    
    self.books = [NSMutableArray arrayWithArray:afterSortedBooks];
}

- (void)replaceBookAtIndex:(NSUInteger)index withBook:(Book *)book
{
    NSMutableArray *books = self.books.mutableCopy;
    [books replaceObjectAtIndex:index withObject:books];
    
    self.books = [NSMutableArray arrayWithArray:books];
}

@end
