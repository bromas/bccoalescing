//
//  BCTestCallBacks.m
//  BCCoalescingSample
//
//  Created by Brian Thomas on 4/24/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import "BCTestCallBacks.h"

@interface BCTestCallBacks ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) CGFloat percentComplete;
@property (nonatomic) BOOL completed;
@property (nonatomic, strong) NSRunLoop *runLoop;

@end

@implementation BCTestCallBacks

- (instancetype)initWithProgress:(void (^)(CGFloat))progressBlock completion:(void (^)(void))completionBlock {
  return [self initWithDuration:2.0 progress:progressBlock completion:completionBlock];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration progress:(void (^)(CGFloat))progressBlock completion:(void (^)(void))completionBlock {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  _progress = progressBlock;
  _completion = completionBlock;
  _duration = duration;
  
  return self;
}

- (void)execute {
  
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.timer invalidate];
    self.timer = nil;
    
    self.percentComplete = 0.0;
    CGFloat interval = self.duration / 10;
    
    self.timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(applyProgress) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:18]];
  });
  
}

- (void)applyProgress {
  if (self.percentComplete < 100.0) {
    self.percentComplete += 10.0;
    dispatch_async(dispatch_get_main_queue(), ^{
      self.progress(self.percentComplete);
    });
  }
  else if (!self.completed) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.completion();
    });
    self.completed = YES;
  }
}

@end
