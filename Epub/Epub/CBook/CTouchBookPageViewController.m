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

@implementation CTouchBookPageViewController

@synthesize URL;
@synthesize webView;
@synthesize bookContainer;
@synthesize currentBook;
@synthesize currentSection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[CommonUtils statusBarView]];
    
    float statusBarHeight = [CommonUtils unnormalizeHeight:[APP STATUS_BAR_HEIGHT]];
    
    UINavigationItem *title = [CommonUtils title:@""];
    UIButton *customBackButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    customBackButtonView.frame =  [CommonUtils makeNormalizeRect:0 top:0 width:162.0f height:65.0f];
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

    
    webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    webView.frame = [CommonUtils makeNormalizeRect:0 top:previewTop width:[APP BASE_WIDTH] height:[APP BASE_HEIGHT] - previewTop];
    [self.view addSubview:self.webView];
    
    
    UIPanGestureRecognizer *backGestureRecognizer
    = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(backGesture:)];
    [self.view addGestureRecognizer:backGestureRecognizer];
    
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.bounces = YES;
    
    bookContainer = [[CBookContainer alloc] initWithURL:URL];
    currentBook = [[self.bookContainer.books objectAtIndex:0] retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long section = [defaults integerForKey:[NSString stringWithFormat:@"section_%@",
                                         [self.currentBook.rootURL absoluteString]]];
    currentSection = [[self.currentBook.sections objectAtIndex:section] retain];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.currentSection.URL];
    [self.webView loadRequest:theRequest];
    
    UISlider *sl = [[UISlider alloc] init];
    sl.frame = [CommonUtils makeNormalizeRect:20.0f top:[APP BASE_HEIGHT] - 100.0f width:600.0f height:30.0f];
    sl.minimumValue = 0.0;
    sl.maximumValue = [self.currentBook.sections count] - 1;
    sl.value = section;
    [sl addTarget:self action:@selector(changeSection:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sl];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView contentOffset].x > [scrollView contentSize].width - scrollView.frame.size.width + 60.0f) {
        [scrollView setScrollEnabled:NO];
        [self nextSection:scrollView];
        [scrollView setScrollEnabled:YES];
    } else if([scrollView contentOffset].x < -60.0f) {
        [scrollView setScrollEnabled:NO];
        [self prevSection:scrollView];
        [scrollView setScrollEnabled:YES];
    }
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

- (void)backGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:sender.view];
    //閾値を良い感じに調整
    if (60.0 < translation.x) {
        [self prevSection:sender];
        [sender setTranslation:CGPointZero inView:self.view];
    } else if (-60.0 > translation.x) {
        [self nextSection:sender];
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

BOOL lock = NO;

- (void) unlock
{
    lock = NO;
}


- (void)prevSection:(id)inSender
{
    if (lock) {
        return;
    }
    lock = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(unlock) userInfo:nil repeats:NO];
    NSUInteger theSectionIndex = [self.currentBook.sections indexOfObject:self.currentSection];
    if (theSectionIndex == 0) {
        return;
    }
    
    self.currentSection = [self.currentBook.sections objectAtIndex:theSectionIndex - 1];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.currentSection.URL];
    [self.webView loadRequest:theRequest];
    [self saveSection:theSectionIndex - 1];
}

- (void)nextSection:(id)inSender
{
    if (lock) {
        return;
    }
    lock = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(unlock) userInfo:nil repeats:NO];
    NSUInteger theSectionIndex = [self.currentBook.sections indexOfObject:self.currentSection];
    if (theSectionIndex == [self.currentBook.sections count] - 1) {
        return;
    }
    
    
    self.currentSection = [self.currentBook.sections objectAtIndex:theSectionIndex + 1];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.currentSection.URL];
    [self.webView loadRequest:theRequest];
    [self saveSection:theSectionIndex + 1];
}

- (void)changeSection:(UISlider *)slider
{
    NSUInteger theSectionIndex = slider.value;
    self.currentSection = [self.currentBook.sections objectAtIndex:theSectionIndex];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.currentSection.URL];
    [self.webView loadRequest:theRequest];
    [self saveSection:theSectionIndex];
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


@end
