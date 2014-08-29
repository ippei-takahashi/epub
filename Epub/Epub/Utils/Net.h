//
//  Net.h
//  GIFMAGAZINE
//
//  Created by katyusha on 2014/04/15.
//  Copyright (c) 2014年 IppeiTakahashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Net : NSObject

+ (void) get:(NSString *)urlString withParameters:(NSDictionary *)params withCallback:(void(^)(NSData *))callback withErrorCallback:(void(^)(NSError *))errorCallback withCallbackInMainThread:(void(^)(NSData *))callbackInMainThread;
+ (void) post:(NSString *)urlString withParameters:(NSDictionary *)params withCallback:(void(^)(NSData *))callback withErrorCallback:(void(^)(NSError *))errorCallback withCallbackInMainThread:(void(^)(NSData *))callbackInMainThread;
+ (NSString *) uriEncodeForString:(NSString *)str;
+ (NSString *) buildParameters:(NSDictionary *)params;

@end
