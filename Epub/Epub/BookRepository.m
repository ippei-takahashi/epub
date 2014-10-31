//
//  BookRepository.m
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "BookRepository.h"
#import "Book.h"

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
    [self.books insertObject:book atIndex:0];
    [self saveBookNames];
}

- (void)removeBook:(Book *)book
{
    [self.books removeObject:book];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:book.fileName error:nil];
    [fileManager removeItemAtPath:[book.fileName stringByDeletingPathExtension] error:nil];
    [self saveBookNames];
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
    [self saveBookNames];
}

- (void)replaceBookAtIndex:(NSUInteger)index withBook:(Book *)book
{
    NSMutableArray *books = self.books.mutableCopy;
    [books replaceObjectAtIndex:index withObject:books];
    
    self.books = [NSMutableArray arrayWithArray:books];
    [self saveBookNames];
}

- (void)saveBookNames
{
    
    NSMutableArray *bookNames = [NSMutableArray array];
    
    for (int i = 0; i < [self.books count]; i++) {
        Book *book = [self.books objectAtIndex:i];
        if (book.progress == 1) {
            [bookNames addObject:book.fileName];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:bookNames forKey:@"bookNames"];
    BOOL successful = [defaults synchronize];
    if (successful) {
        NSLog(@"%@", @"データの保存に成功しました。");
    }
}

- (NSArray *)loadBookNames
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"bookNames"];
}

@end
