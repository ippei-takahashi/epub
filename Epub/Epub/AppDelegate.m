//
//  AppDelegate.m
//  Epub
//
//  Created by katyusha on 2014/08/26.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "AppDelegate.h"
#import "BooksViewController.h"

@interface AppDelegate()

@property(nonatomic, readwrite) CGFloat BASE_WIDTH;
@property(nonatomic, readwrite) CGFloat BASE_HEIGHT;
@property(nonatomic, readwrite) CGFloat WINDOW_WIDTH;
@property(nonatomic, readwrite) CGFloat WINDOW_HEIGHT;
@property(nonatomic, readwrite) CGFloat STATUS_BAR_HEIGHT;
@property(nonatomic, readwrite) CGRect BOUNDS_RECT;

@property(nonatomic, readwrite) BooksViewController *booksViewController;

@end

@implementation AppDelegate

- (id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.BOUNDS_RECT = [[UIScreen mainScreen] bounds];
    self.WINDOW_WIDTH = self.BOUNDS_RECT.size.width;
    self.WINDOW_HEIGHT = self.BOUNDS_RECT.size.height;
    self.BASE_WIDTH = 640.0f;
    self.BASE_HEIGHT = 1136.0f;
    
    self.downloadingBookQueue = [NSMutableArray array];
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.STATUS_BAR_HEIGHT = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.booksViewController = [[BooksViewController alloc] init];
    self.window.rootViewController = self.booksViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *query = [[url absoluteString]
                       stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@"%@://", [url scheme]]
                       withString:@"http://"];
    
    NSURL *downloadUrl = [NSURL URLWithString:query];
    
    self.booksViewController.downloadUrl = downloadUrl;

    [self.booksViewController dismissViewControllerAnimated:YES completion:nil];
    if (sourceApplication) {
        [self.booksViewController setup];
    }

    return YES;
}


@end
