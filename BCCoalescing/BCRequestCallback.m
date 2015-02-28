//
//  BCRequestCallback.m
//  BCCoalescingSample
//
//  Created by Brian Thomas on 2/11/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import "BCRequestCallback.h"

@implementation BCRequestCallback

+ (instancetype)callBackWithProgress:(BCProgressBlock)progressBlock andCompletion:(BCCompletionBlock)completionBlock
{
  return [[BCRequestCallback alloc] initWithProgress:progressBlock andCompletion:completionBlock];
}

- (id)initWithProgress:(BCProgressBlock)progressBlock andCompletion:(BCCompletionBlock)completionBlock
{
  self = [super init];
  if (!self)
    return nil;
  
  self.progress = progressBlock;
  self.completion = completionBlock;
  
  return self;
}

@end
