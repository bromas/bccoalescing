//
//  BCCoalesce.h
//  BCCoalescingSample
//
//  Created by Brian Thomas on 2/11/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

@import Foundation;
@import QuartzCore;

typedef void (^BCProgressBlock)(CGFloat percent);
typedef void (^BCCompletionBlock)(id result, NSURLResponse *response, NSError *error);
typedef void(^BCPerformRequestBlock)(void);
@class BCRequestCallback;
@class BCRegistrationToken;

@interface BCCoalesce : NSObject

/**
 Defaults to NO and callbacks will be peformed on the thread in which the coalescer was initialized.
 */
@property (nonatomic, assign) BOOL shouldPerformCallbacksOnMainThread;

/**
 Interpolation to be run on the resultant data before it is passed into the registered completion blocks.
 */
@property (nonatomic, copy) id (^resultsInterpolator)(id input);

/**
 Block called 
 */
@property (nonatomic, copy) void (^unregisteredBlock)(NSString *identifier);

/**
 Suspends callbacks until resumed (suspendCallBacks = NO).
 */
@property (nonatomic, assign) BOOL suspendCallBacks;

/**
 Call invalidate in the returned RegistrationToken to remove callbacks
 */
- (BCRegistrationToken *)addCallbackWithProgress:(BCProgressBlock)progress andCompletion:(BCCompletionBlock)completion forIdentifier:(NSString *)identifier withRequestPerformanceBlock:(BCPerformRequestBlock)performRequestBlock;

- (void)identifier:(NSString *)identifier progressed:(CGFloat)progress;
- (void)identifier:(NSString *)identifier completedWithData:(NSData *)data andError:(NSError *)error;
- (void)identifier:(NSString *)identifier completedWithData:(NSData *)data response:(NSURLResponse *)response andError:(NSError *)error;

/**
 An internal method called by the BCRegistrationToken to unregister callbacks
 */
- (void)removeCallback:(id)callBack forIdentifier:(NSString *)identifier;

@end
