//
//  TouchBookViewController.m
//  TouchBook
//
//  Created by Jonathan Wight on 02/09/10.
//  Copyright toxicsoftware.com 2010. All rights reserved.
//

#import "CTouchBookPageViewController.h"

#import "CBookContainer.h"
#import "CBook.h"
#import "CSection.h"
#import "CommonUtils.h"

@interface CTouchBookPageViewController()
@property (readwrite, nonatomic, retain) UISlider *slider;
@property (readwrite, nonatomic, retain) UIScrollView *scrollView;
@end

@implementation CTouchBookPageViewController

@synthesize URL;
@synthesize bookContainer;
@synthesize currentBook;
@synthesize currentSection;
@synthesize webViews;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webViews = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[CommonUtils statusBarView]];
    
    float statusBarHeight = [CommonUtils unnormalizeHeight:[APP STATUS_BAR_HEIGHT]];
    
    UINavigationItem *title = [CommonUtils title:@""];
    UIButton *customBackButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    customBackButtonView.frame = CGRectMake(0, 0, 81.0f, 32.0f);
    [customBackButtonView setBackgroundImage:[UIImage imageNamed:@"btn_library_5s.png"] forState:UIControlStateNormal];
    [customBackButtonView addTarget:self
                             action:@selector(sendToTop:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBackButtonView];
    
    title.leftBarButtonItem = backButtonItem;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.frame = [CommonUtils makeNormalizeRect:0 top:statusBarHeight width:640.0f height:88.0f];
    [navBar pushNavigationItem:title animated:YES];
    
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [self.view addSubview:navBar];
    
    
    float previewTop = statusBarHeight + [CommonUtils unnormalizeHeight:navBar.frame.size.height];

    bookContainer = [[CBookContainer alloc] initWithURL:URL];
    currentBook = [[self.bookContainer.books objectAtIndex:0] retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long section = [defaults integerForKey:[NSString stringWithFormat:@"section_%@",
                                         [self.currentBook.rootURL absoluteString]]];
    currentSection = [[self.currentBook.sections objectAtIndex:section] retain];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.frame = [CommonUtils makeNormalizeRect:0 top:previewTop width:[APP BASE_WIDTH] height:[APP BASE_HEIGHT] - previewTop];
    
    CGSize s = _scrollView.frame.size;
    CGRect contentRect = CGRectMake(0, 0, s.width * [self.currentBook.sections count], s.height);
    UIView *contentView = [[UIView alloc] initWithFrame:contentRect];
    
    for (int i = 0; i < [self.currentBook.sections count]; i++) {
        UIWebView *webView = [[UIWebView alloc] init];
        webView.scalesPageToFit = YES;
        webView.scrollView.bounces = NO;
        webView.frame = [CommonUtils makeNormalizeRect:([self.currentBook.sections count] - 1 - i) * [APP BASE_WIDTH] top:0 width:[APP BASE_WIDTH] height:[APP BASE_HEIGHT] - previewTop];
        [contentView addSubview:webView];
        webView.dataDetectorTypes = UIDataDetectorTypeNone;
        
        [self.webViews addObject:webView];
    }
    
    [self loadPage:section];
    
    
    [_scrollView addSubview:contentView];
    _scrollView.contentSize = contentView.frame.size;
    _scrollView.contentOffset = CGPointMake([APP WINDOW_WIDTH] * ([self.currentBook.sections count] - 1 - section), 0);
    [self.view addSubview:_scrollView];

    
    _slider = [[UISlider alloc] init];
    _slider.frame = [CommonUtils makeNormalizeRect:20.0f top:[APP BASE_HEIGHT] - 100.0f width:600.0f height:30.0f];
    _slider.minimumValue = 0.0;
    _slider.maximumValue = [self.currentBook.sections count] - 1;
    _slider.value = [self.currentBook.sections count] - 1 - section;
    _slider.minimumTrackTintColor = [UIColor lightGrayColor];
    [_slider addTarget:self action:@selector(changeSection:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    long page = [self.currentBook.sections count] - 1 - (offset.x - ([APP WINDOW_WIDTH] / 2)) / [APP WINDOW_WIDTH];
    NSUInteger theSectionIndex = [self.currentBook.sections indexOfObject:self.currentSection];
    
    if (page < 0 || page > [self.currentBook.sections count] - 1) {
        return;
    }

    
    // 現在表示しているページ番号と異なる場合には、
    // ページ切り替わりと判断し、処理を呼び出します。
    if (theSectionIndex != page) {
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        
        dispatch_async(q_global, ^{
            self.currentSection = [self.currentBook.sections objectAtIndex:page];
            [self saveSection:page];
            _slider.value = [self.currentBook.sections count] - 1 - (page);

            dispatch_async(q_main, ^{
                [self loadPage:page];
            });
        });
    }
}

- (void)loadPage:(long)page {
    long nextPage = page + 1;
    long prevPage = page - 1;
    
    if (nextPage < [self.currentBook.sections count]) {
        UIWebView *webView = [self.webViews objectAtIndex:nextPage];
        
        if (!webView.loading) {
            CSection *section = [self.currentBook.sections objectAtIndex:nextPage];
            NSURLRequest *theRequest = [NSURLRequest requestWithURL:section.URL];
            [webView loadRequest:theRequest];
        }
    }
    
    if (prevPage >= 0) {
        UIWebView *webView = [self.webViews objectAtIndex:prevPage];
        
        if (!webView.loading) {
            CSection *section = [self.currentBook.sections objectAtIndex:prevPage];
            NSURLRequest *theRequest = [NSURLRequest requestWithURL:section.URL];
            [webView loadRequest:theRequest];
        }
    }
    
    for (int i = 2; i < 10; i++) {
        [self stopLoadPage:page + i];
        [self stopLoadPage:page - i];
    }
    
    UIWebView *webView = [self.webViews objectAtIndex:page];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.currentSection.URL];
    [webView loadRequest:theRequest];
}

- (void)stopLoadPage:(long)page {
    if (page < 0 || page >= [self.currentBook.sections count]) {
        return;
    }
    
    UIWebView *webView = [self.webViews objectAtIndex:page];
    [webView stopLoading];
    [webView loadHTMLString:@"" baseURL:nil];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)changeSection:(UISlider *)slider
{
    CGPoint offset;
    
    offset.x = (int)slider.value * [APP WINDOW_WIDTH];
    offset.y = 0.0f;
    
    [_scrollView setContentOffset:offset animated:NO];
}


- (void)saveSection:(NSUInteger)section
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:section forKey:[NSString stringWithFormat:@"section_%@",
                                         [self.currentBook.rootURL absoluteString]]];
    BOOL successful = [defaults synchronize];
    if (successful) {
        NSLog(@"section = %ld", section);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)sendToTop:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIWebView *wv in self.webViews) {
        wv.delegate = nil;
        [wv stopLoading];
        [wv loadHTMLString:@"" baseURL:nil];
        
        [wv removeFromSuperview];
        [wv release];
        wv = nil;
    }
    
    [self.webViews removeAllObjects];
    [self.webViews release];
    
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
    
    [bookContainer release];
    [currentBook release];
    [currentSection release];
}


@end
