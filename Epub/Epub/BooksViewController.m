//
//  ViewController.m
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "BooksViewController.h"
#import "BookRepository.h"
#import "UICollectionView+Draggable.h"
#import "BooksViewCell.h"
#import "Book.h"
#import "DraggableCollectionViewFlowLayout.h"
#import "CommonUtils.h"
#import "CTouchBookPageViewController.h"
#import "BookStoreViewController.h"
#import "CBook.h"
#import "CBookContainer.h"
#import "NSMutableArray+QueueAdditions.h"
#import <objc/runtime.h>

static NSString *const CellReuseIdentifier = @"BooksCollectionViewCellReuseIdentifier";


@interface BooksViewController () <UICollectionViewDataSource_Draggable, UICollectionViewDelegate>

@property (nonatomic) BOOL editing;
@property (nonatomic) BOOL isDeleteMode;

@property (nonatomic) NSMutableData *downloadData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property (nonatomic) Book *downloadingBook;
@property (nonatomic) NSMutableArray *downloadingBookQueue;


@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic) BookRepository *repository;

@end

@implementation BooksViewController

@synthesize downloadUrl;

float topCriteria = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isDeleteMode = NO;
        _repository = [BookRepository new];
                
        // ファイルマネージャを作成
        NSFileManager *fileManager = [NSFileManager defaultManager];
        

//        NSArray *list = @[@"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/default.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga2.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga3.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga4.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga5.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga6.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga7.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga8.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga9.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga10.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga11.epub",
//                          @"/Users/pony/Library/Application Support/iPhone Simulator/7.1-64/Applications/D63E6EBF-FD10-44E3-A320-E9584F9BA1D9/Documents/mannga12.epub"];
        
        NSArray *list = [self.repository loadBookNames];
        
        
        for (NSString *fileName in list) {
            BOOL isDirectory = NO;
            [fileManager fileExistsAtPath:fileName isDirectory:&isDirectory];
            
            if (isDirectory) {
                continue;
            }
            
            if (![[[fileName lastPathComponent] pathExtension] isEqual:@"epub"]) {
                continue;
            }
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(0, 0, 60, 80);
            
            CBookContainer *bookContainer = [[CBookContainer alloc] initWithURL:[NSURL fileURLWithPath:fileName]];
            UIImage *image = ((CBook *)[bookContainer.books objectAtIndex:0]).cover;
            
            if (image) {
                imageView.image = image;
                imageView.backgroundColor = [UIColor clearColor];
            } else {
                imageView.backgroundColor = [UIColor whiteColor];
            }
            
            
            [self.repository addBook:[[Book alloc] initWithDictionary:
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       imageView, @"imageView",
                                       @"1", @"progress",
                                       fileName, @"fileName",
                                       nil]]];
        }
        
        
        self.editing = NO;
        _downloadingBookQueue = [NSMutableArray array];
        topCriteria = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    BOOL startDownload = NO;
    
    if (downloadUrl) {
        NSString *name = [downloadUrl lastPathComponent];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        filePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@", name]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:filePath] ||
            ![[[filePath lastPathComponent] pathExtension] isEqual:@"epub"]) {
            downloadUrl = nil;
        } else {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(0, 0, 60, 80);
            imageView.backgroundColor = [UIColor whiteColor];
            Book * book = [[Book alloc] initWithDictionary:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           imageView, @"imageView",
                           @"0", @"progress",
                           filePath, @"fileName",
                           downloadUrl, @"downloadUrl",
                           nil]];
            [self.repository addBook:book];
            if (!_downloadingBook) {
                startDownload = YES;
                _downloadingBook = book;
            } else {
                [_downloadingBookQueue enqueue:book];
            }
        }
    }
    
    [self.view addSubview:[CommonUtils statusBarView]];
    
    float statusBarHeight = [CommonUtils unnormalizeHeight:[APP STATUS_BAR_HEIGHT]];
    
    UINavigationItem *title = [CommonUtils title];
    UIButton *customBackButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    customBackButtonView.frame =  [CommonUtils makeNormalizeRect:0 top:0 width:92.0f height:65.0f];
    [customBackButtonView setBackgroundImage:[UIImage imageNamed:@"btn_store_5s.png"] forState:UIControlStateNormal];
    [customBackButtonView addTarget:self
                             action:@selector(sendToStore:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBackButtonView];
    
    
    UIButton *customNextButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    customNextButtonView.frame =  [CommonUtils makeNormalizeRect:0 top:0 width:92.0f height:65.0f];
    [customNextButtonView setBackgroundImage:[UIImage imageNamed:@"btn_delete_5s.png"] forState:UIControlStateNormal];
    [customNextButtonView addTarget:self
                             action:@selector(toggleDeleteMode:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customNextButtonView];
    
    title.leftBarButtonItem = backButtonItem;
    title.rightBarButtonItem = nextButtonItem;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.frame = [CommonUtils makeNormalizeRect:0 top:statusBarHeight width:640.0f height:88.0f];
    [navBar pushNavigationItem:title animated:YES];
    
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [self.view addSubview:navBar];
    
    float previewTop = statusBarHeight + [CommonUtils unnormalizeHeight:navBar.frame.size.height];
    
    UIScrollView *sv = [[UIScrollView alloc] init];
    sv.frame = [CommonUtils makeNormalizeRect:0 top:previewTop width:[APP BASE_WIDTH] height:[APP BASE_HEIGHT] - previewTop];
    sv.bounces = NO;

    for (int i = 0; i < [self.repository.books count] / 3 + 1; i++) {
        UIImageView *backgroundImageView = [[UIImageView alloc]
                                            initWithImage:[UIImage imageNamed:i == 0 ? @"hondana_head.jpg" : @"hondana.jpg"]];
        backgroundImageView.frame = [CommonUtils makeNormalizeRect:0 top: topCriteria width:[APP BASE_WIDTH] height:222.0];
        [sv addSubview:backgroundImageView];
        topCriteria += 222.0;
    }
    
    
    
    DraggableCollectionViewFlowLayout *layout = [[DraggableCollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc]
                           initWithFrame:[CommonUtils makeNormalizeRect:80 top:40 width:480 height:topCriteria]
                           collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.draggable = YES;
    [self.collectionView registerClass:[BooksViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [sv addSubview:self.collectionView];
    
    if (startDownload) {
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadUrl];
        NSURLConnection *connection = [[NSURLConnection alloc]
                                       initWithRequest:request delegate:self startImmediately:YES];
    }
    
    sv.contentSize = CGSizeMake([APP WINDOW_WIDTH], topCriteria  * [APP WINDOW_HEIGHT] / [APP BASE_HEIGHT]);
    [self.view addSubview:sv];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer =
    [self longPressGestureRecognizerForCollectionView];
    
    [longPressGestureRecognizer addTarget:self
                                   action:@selector(collectionViewDidLongPress:)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    UILongPressGestureRecognizer *longPressGestureRecognizer =
    [self longPressGestureRecognizerForCollectionView];
    
    [longPressGestureRecognizer removeTarget:self
                                      action:@selector(collectionViewDidLongPress:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.repository.books.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BooksViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier
                                              forIndexPath:indexPath];
    [cell setBook:self.repository.books[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    [cell addSubview:cell.imageView];
    
    if (cell.progress == 1) {
        void (^sendToDetail)(id) = ^(id selector) {
            [self sendToDetail:selector withUrl:[NSURL fileURLWithPath:cell.fileName]];
        };
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"removeBook%ld", indexPath.row]);
        IMP imp = imp_implementationWithBlock(sendToDetail);
        class_replaceMethod([self class], sel, imp, nil);
        UITapGestureRecognizer *sendToDetailGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
        cell.imageView.userInteractionEnabled = YES;
        [cell.imageView addGestureRecognizer:sendToDetailGesture];
        
        if (_isDeleteMode) {
            UIButton *deleteButtonView = [[UIButton alloc]
                                          initWithFrame:[CommonUtils makeNormalizeRect:0 top:0 width:40 height:40]];
            [deleteButtonView setTitle:@"×" forState:UIControlStateNormal];
            deleteButtonView.backgroundColor = [UIColor redColor];
            [cell addSubview:deleteButtonView];
            
            void (^removeBook)(id) = ^(id selector) {
                [self removeBook:selector withBook:self.repository.books[indexPath.row]];
            };
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"removeBook%ld", indexPath.row]);
            IMP imp = imp_implementationWithBlock(removeBook);
            class_replaceMethod([self class], sel, imp, nil);
            [deleteButtonView addTarget:self
                                 action:sel forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        UIProgressView *pv = [[UIProgressView alloc]
                              initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv.frame = CGRectMake(5, 60, 50, 10);
        pv.progress = cell.progress;
        [cell addSubview:pv];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.repository moveBookAtIndex:fromIndexPath.row
                             toIndex:toIndexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (void)collectionViewDidTap:(UITapGestureRecognizer *)sender
{
    [self changeEditingState:NO];
}

- (void)collectionViewDidLongPress:(UILongPressGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    if (state == UIGestureRecognizerStateBegan &&
        !self.editing) {
        [self changeEditingState:YES];
    }
}

- (void)changeEditingState:(BOOL)editing
{
    _editing = editing;
}

- (void)toggleDeleteMode:(id)sender
{
    _isDeleteMode = !_isDeleteMode;
    [self.collectionView reloadData];
}

- (void)removeBook:(id)sender withBook:(Book *)book
{
    [self.repository removeBook:book];
    [self.collectionView reloadData];
}

- (void)sendToStore:(id)sender
{
    BookStoreViewController *vc = [[BookStoreViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)sendToDetail:(id)sender withUrl:(NSURL *)url
{
    CTouchBookPageViewController *vc = [[CTouchBookPageViewController alloc] init];
    vc.URL = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 101);
}


- (UILongPressGestureRecognizer *)longPressGestureRecognizerForCollectionView
{
    NSArray *recognizers = self.collectionView.gestureRecognizers;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    
    for (UIGestureRecognizer *recognizer in recognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            longPressGestureRecognizer = (UILongPressGestureRecognizer *)recognizer;
        }
    }
    
    return longPressGestureRecognizer;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    
    self.downloadData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.downloadData appendData:data];
    self.receivedBytes += data.length;
    
    _downloadingBook.progress = (double)self.receivedBytes / (double)self.totalBytes;
    [self.collectionView reloadData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *name = [downloadUrl lastPathComponent];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@", name]];
    
    _downloadingBook.progress = 1;
    [self.collectionView reloadData];
    
    if ([self.downloadData writeToFile:filePath atomically:YES]) {
        NSLog(@"%@", filePath);
    }
    _downloadingBook = _downloadingBookQueue.dequeue;
    if (_downloadingBook) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_downloadingBook.downloadUrl];
        NSURLConnection *connection = [[NSURLConnection alloc]
                                       initWithRequest:request delegate:self startImmediately:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //handle error
}


@end
