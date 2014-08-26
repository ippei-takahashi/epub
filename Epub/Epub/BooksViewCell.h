//
//  BooksViewControllerCell.h
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface BooksViewCell : UICollectionViewCell

@property (nonatomic) Book *book;
@property (weak, nonatomic) UIImageView *imageView;

@end
