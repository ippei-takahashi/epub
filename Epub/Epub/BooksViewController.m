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

static NSString *const CellReuseIdentifier = @"BooksCollectionViewCellReuseIdentifier";


@interface BooksViewController () <UICollectionViewDataSource_Draggable, UICollectionViewDelegate>

@property (nonatomic) BOOL editing;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic) BookRepository *repository;

@end

@implementation BooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _repository = [BookRepository new];
        
        for (int i = 0; i < 10; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(0, 0, 30, 30);
            imageView.backgroundColor = [UIColor whiteColor];
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
    
    DraggableCollectionViewFlowLayout *layout = [[DraggableCollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 239.0f, 139.0f) collectionViewLayout:layout];
    self.collectionView.draggable = YES;
    [self.collectionView registerClass:[BooksViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.view addSubview:self.collectionView];
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
    [cell addSubview:cell.imageView];
    
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
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
