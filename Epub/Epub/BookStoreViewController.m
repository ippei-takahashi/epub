//
//  BookStoreViewController.m
//  Epub
//
//  Created by ポニー村山 on 2014/09/24.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "BookStoreViewController.h"
#import "CommonUtils.h"

@implementation BookStoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:[CommonUtils statusBarView]];
    
    float statusBarHeight = [CommonUtils unnormalizeHeight:[APP STATUS_BAR_HEIGHT]];
    
    UINavigationItem *title = [CommonUtils title];
    UIButton *customBackButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    customBackButtonView.frame =  [CommonUtils makeNormalizeRect:0 top:0 width:92.0f height:65.0f];
    [customBackButtonView setBackgroundImage:[UIImage imageNamed:@"btn_store_5s.png"] forState:UIControlStateNormal];
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

    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = [CommonUtils makeNormalizeRect:0 top:previewTop width:[APP BASE_WIDTH] height:[APP BASE_HEIGHT] - previewTop];
    [self.view addSubview:webView];
    
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    
    dispatch_async(q_global, ^{
        dispatch_async(q_main, ^{
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://image.webcustom.net/"]]];
        });
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)sendToTop:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
