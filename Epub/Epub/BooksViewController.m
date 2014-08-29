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
#import <objc/runtime.h>

static NSString *const CellReuseIdentifier = @"BooksCollectionViewCellReuseIdentifier";


@interface BooksViewController () <UICollectionViewDataSource_Draggable, UICollectionViewDelegate>

@property (nonatomic) BOOL editing;
@property (nonatomic) BOOL isDeleteMode;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic) BookRepository *repository;

@end

@implementation BooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _repository = [BookRepository new];
        _isDeleteMode = NO;
        
        for (int i = 0; i < 10; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(0, 0, 60, 100);
            imageView.image = [UIImage imageNamed:@"book.jpg"];
            imageView.backgroundColor = [UIColor clearColor];
            [self.repository addBook:[[Book alloc] initWithDictionary:
                                                        [NSDictionary dictionaryWithObject:imageView forKey:@"imageView"]]];
        }
        
        self.editing = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImageView *backgroundImageView = [[UIImageView alloc]
                                        initWithImage:[UIImage imageNamed:@"hondana_5s.jpg"]];
    backgroundImageView.frame = [CommonUtils makeNormalizeRect:0 top:0 width:[APP BASE_WIDTH] height:[APP BASE_HEIGHT]];
    [self.view addSubview:backgroundImageView];

    
    DraggableCollectionViewFlowLayout *layout = [[DraggableCollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc]
                           initWithFrame:[CommonUtils makeNormalizeRect:40 top:160 width:[APP BASE_WIDTH] - 80 height:[APP BASE_HEIGHT]]
                           collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.draggable = YES;
    [self.collectionView registerClass:[BooksViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.view addSubview:self.collectionView];
    
    UIButton *deleteButtonView = [[UIButton alloc]
                                  initWithFrame:[CommonUtils makeNormalizeRect:500 top:60 width:100 height:60]];
    [deleteButtonView setTitle:@"削除" forState:UIControlStateNormal];
    [self.view addSubview:deleteButtonView];
    [deleteButtonView addTarget:self
                         action:@selector(toggleDeleteMode:) forControlEvents:UIControlEventTouchUpInside];

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



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 130);
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


@end
