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

@implementation CTouchBookPageViewController

@synthesize URL;
@synthesize webView;
@synthesize bookContainer;
@synthesize currentBook;
@synthesize currentSection;

- (void)viewDidLoad
{
[super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    UIPanGestureRecognizer *backGestureRecognizer
    = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(backGesture:)];
    [self.view addGestureRecognizer:backGestureRecognizer];
    
//

//NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Dumas - The Count of Monte Cristo" ofType:@"epub"];
//NSString *thePath = [[NSBundle mainBundle] pathForResource:@"melville-moby-dick" ofType:@"epub"];
//NSString *thePath = self.URL.path;
//thePath = [(id)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)thePath, NULL, NULL, kCFStringEncodingUTF8) autorelease];

//NSString *theString = [NSString stringWithFormat:@"x-zipfile://%@/", thePath];
//NSURL *theURL = [NSURL URLWithString:theString];

bookContainer = [[CBookContainer alloc] initWithURL:URL];
currentBook = [[self.bookContainer.books objectAtIndex:0] retain];
currentSection = [[self.currentBook.sections objectAtIndex:0] retain];

NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.currentSection.URL];
[self.webView loadRequest:theRequest];
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
}

@end
