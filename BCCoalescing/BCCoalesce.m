//
//  BCCoalesce.m
//  BCCoalescingSample
//
//  Created by Brian Thomas on 2/11/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import "BCCoalesce.h"
#import "BCRequestCallback.h"

@interface BCCoalesce ()

@property (nonatomic, strong) NSMutableDictionary *requests; /* dictionary of mutable arrays to store completion blocks */
@property (nonatomic, strong) NSOperationQueue *requestQueue; /* request queue where all access to the active requests and callbacks is handled */

@end

@implementation BCCoalesce

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _requests = @{}.mutableCopy;
    _requestQueue = [NSOperationQueue new];
    _requestQueue.maxConcurrentOperationCount = 1;
    _shouldPerformCallbacksOnMainThread = NO;
    _suspendCallBacks = NO;
    _resultsInterpolator = ^(id input){
        return input;
    };
    
    return self;
}

- (void)setSuspendCallBacks:(BOOL)suspendCallBacks
{
    self.requestQueue.suspended = suspendCallBacks;
    _suspendCallBacks = suspendCallBacks;
}

- (void)addCallbacksWithProgress:(BCProgressBlock)progress andCompletion:(BCCompletionBlock)completion forIdentifier:(NSString *)identifier withRequestPerformanceBlock:(BCPerformRequestBlock)performRequestBlock
{
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *addNewCallbacksOperation = [NSBlockOperation blockOperationWithBlock:^{
        BCRequestCallback *callBack = [BCRequestCallback callBackWithProgress:progress andCompletion:completion];
        
        NSMutableArray *currentCallBacks = [self activeCallBacksForIdentifier:identifier];
        BOOL shouldPerformRequest = [currentCallBacks count] > 0 ? NO : YES; /* if there is an object in this array a previous request is active for this file path */
        
        [currentCallBacks addObject:callBack];
        
        if (shouldPerformRequest && performRequestBlock) {
            performRequestBlock();
        }
    }];
    addNewCallbacksOperation.queuePriority = NSOperationQueuePriorityHigh;
    [weakSelf.requestQueue addOperation:addNewCallbacksOperation];
}

- (NSMutableArray *)activeCallBacksForIdentifier:(NSString *)identifier
{
    NSMutableArray *callBacks = [self.requests objectForKey:identifier];
    if (!callBacks)
        callBacks = @[].mutableCopy;
    
    [self.requests setObject:callBacks forKey:identifier];
    
    return callBacks;
}

- (void)identifier:(NSString *)identifier progressed:(CGFloat)progress
{
    __weak typeof(self) weakSelf = self;
    [self.requestQueue addOperationWithBlock:^{
        NSMutableArray *callBacks = [weakSelf.requests objectForKey:identifier];
        if (self.shouldPerformCallbacksOnMainThread) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                for (BCRequestCallback *callBack in callBacks) {
                    if (callBack.progress)
                        callBack.progress(progress);
                }
            }];
        }
        else {
            for (BCRequestCallback *callBack in callBacks) {
                if (callBack.progress)
                    callBack.progress(progress);
            }
        }
    }];
}

- (void)identifier:(NSString *)identifier completedWithData:(NSData *)data andError:(NSError *)error
{
    [self identifier:identifier completedWithData:data response:nil andError:error];
}

- (void)identifier:(NSString *)identifier completedWithData:(NSData *)data response:(NSURLResponse *)response andError:(NSError *)error
{
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray *callBacks = [weakSelf.requests objectForKey:identifier];
        id interpolatedData = self.resultsInterpolator(data);
        for (BCRequestCallback *callBack in callBacks) {
            if (callBack.completion) {
                if (self.shouldPerformCallbacksOnMainThread) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        callBack.completion(interpolatedData, response, error);
                    }];
                }
                else {
                    callBack.completion(interpolatedData, response, error);
                }
            }
        }
        [self.requests removeObjectForKey:identifier];
    }];
    completionOperation.queuePriority = NSOperationQueuePriorityLow;
    
    [self.requestQueue addOperation:completionOperation];
}

@end