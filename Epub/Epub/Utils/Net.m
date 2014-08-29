//
//  Net.m
//  GIFMAGAZINE
//
//  Created by katyusha on 2014/04/15.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import "Net.h"

@implementation Net

+ (void) get:(NSString *)urlString withParameters:(NSDictionary *)params withCallback:(void(^)(NSData *))callback withErrorCallback:(void(^)(NSError *))errorCallback withCallbackInMainThread:(void(^)(NSData *))callbackInMainThread
{
    [self sendRequest:urlString withParameters:params withCallback:callback withErrorCallback:errorCallback withCallbackInMainThread:callbackInMainThread method:@"GET"];
}

+ (void) post:(NSString *)urlString withParameters:(NSDictionary *)params withCallback:(void(^)(NSData *))callback withErrorCallback:(void(^)(NSError *))errorCallback withCallbackInMainThread:(void(^)(NSData *))callbackInMainThread
{
    [self sendRequest:urlString withParameters:params withCallback:callback withErrorCallback:errorCallback withCallbackInMainThread:callbackInMainThread method:@"POST"];
}

+ (void) sendRequest:(NSString *)urlString withParameters:(NSDictionary *)params withCallback:(void(^)(NSData *))callback withErrorCallback:(void(^)(NSError *))errorCallback withCallbackInMainThread:(void(^)(NSData *))callbackInMainThread method:(NSString *)method
{
    NSString *bodyString = [Net buildParameters:params];
    NSData   *httpBody   = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request;
    if ([method isEqualToString:@"POST"]) {
        NSURL *url = [NSURL URLWithString:urlString];
        request = [[NSMutableURLRequest alloc] initWithURL:url
                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                           timeoutInterval:20];
        // POST の HTTP Request を作成
        [request setHTTPMethod:method];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", [httpBody length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:httpBody];
        [request setHTTPShouldHandleCookies:YES];
    } else {
        NSString *urlStringWithParams = [NSString stringWithFormat:@"%@?%@", urlString, bodyString];
        //NSLog(@"%@", urlStringWithParams);
        NSURL *url = [NSURL URLWithString:urlStringWithParams];
        request = [[NSMutableURLRequest alloc] initWithURL:url
                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                           timeoutInterval:20];

    }

    
    // POST 送信
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            // エラー処理を行う。
            if (error.code == -1003) {
                NSLog(@"not found hostname. targetURL=%@", urlString);
            } else if (-1019) {
                NSLog(@"auth error. reason=%@", error);
            } else {
                NSLog(@"unknown error occurred. reason = %@", error);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorCallback) {
                    errorCallback(error);
                } else {
                    UIAlertView *alert =
                    [[UIAlertView alloc] initWithTitle:@"ネットワークエラー" message:@"暫くたってから再度お試しください" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }
            });
            
        } else {
            NSInteger httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (httpStatusCode == 404) {
                NSLog(@"404 NOT FOUND ERROR. targetURL=%@", urlString);
            } else {
//                NSLog(@"success request!!");
//                NSLog(@"statusCode = %ld", ((NSHTTPURLResponse *)response).statusCode);
//                NSLog(@"responseText = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                if (callback) {
                    callback(data);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // メインスレッドで処理する内容
                    if (callbackInMainThread) {
                        callbackInMainThread(data);
                    }
                });
            }
        }
    }];
}


+ (NSString *) uriEncodeForString:(NSString *)str
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}

+ (NSString *) buildParameters:(NSDictionary *)params
{
    NSMutableString *s = [NSMutableString string];
    
    NSString *key;
    for ( key in params ) {
        NSString *uriEncodedValue = [Net uriEncodeForString:[params objectForKey:key]];
        [s appendFormat:@"%@=%@&", key, uriEncodedValue];
    }
    
    if ( [s length] > 0 ) {
        [s deleteCharactersInRange:NSMakeRange([s length]-1, 1)];
    }
    return s;
}
@end
