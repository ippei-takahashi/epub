//
//  ViewController.h
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BooksViewController : UIViewController <NSURLConnectionDataDelegate>

@property (readwrite, nonatomic, retain) NSURL *downloadUrl;

@end
