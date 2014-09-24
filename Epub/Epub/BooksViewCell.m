//
//  BooksViewControllerCell.m
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "BooksViewCell.h"

#import "Book.h"

@interface BooksViewCell ()

@end


@implementation BooksViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setBook:(Book *)book
{
    _book = book;
    
    _imageView = book.imageView;
    _progress = book.progress;
    _fileName = book.fileName;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
