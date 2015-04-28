//
//  BCRegistrationToken.m
//  BCCoalescingSample
//
//  Created by Brian Thomas on 4/22/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import "BCRegistrationToken.h"

@interface BCRegistrationToken ()

@property (nonatomic, weak) BCCoalesce *coalescer;
@property (nonatomic, copy) NSString *requestIdentifier;
@property (nonatomic, strong) BCRequestCallback *callBack;
@property (nonatomic) BOOL invalidated;

@end

@implementation BCRegistrationToken

- (instancetype) init {
  NSAssert(false, @"To create a BCRegistrationToken, use an initWith... initializer.");
  return self;
}

- (instancetype)initWithCoalescer:(BCCoalesce *)coalescer identifier:(NSString *)identifier andCallBack:(BCRequestCallback *)callBack {
  
  if (self == [super init]) {
    _coalescer = coalescer;
    _requestIdentifier = identifier;
    _callBack = callBack;
    _invalidated = NO;
  }
  
  return self;
  
}

- (void)dealloc {
  [self invalidate];
}

- (void)invalidate {
  if (self.invalidated) {
    return;
  }
  [self.coalescer removeCallback:self.callBack forIdentifier:self.requestIdentifier];
  self.coalescer = nil;
  self.callBack = nil;
  self.requestIdentifier = nil;
  self.invalidated = YES;
}

@end
