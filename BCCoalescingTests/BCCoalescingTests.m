//
//  BCCoalescingTests.m
//  BCCoalescingTests
//
//  Created by Brian Thomas on 2/11/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
@import Quartz;
#import "BCCoalescingOSX.h"

@interface CallBackPerformer : NSObject

@property (nonatomic, copy) void (^progress)(void);
@property (nonatomic, copy) void (^completion)(void);

- (instancetype)initWithProgress:(void (^)(void))progressBlock completion:(void (^)(void))completionBlock;

@end

@implementation CallBackPerformer

- (instancetype)initWithProgress:(void (^)(void))progressBlock completion:(void (^)(void))completionBlock {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  _progress = progressBlock;
  _completion = completionBlock;
  
  return self;
}

- (void)execute {
  self.progress();
  self.completion();
}

@end

@interface BCCoalescingTests : XCTestCase

@property (nonatomic, strong) BCCoalesce *testCoalescer;
@property (nonatomic, strong) CallBackPerformer *performer;

@end

@implementation BCCoalescingTests

- (void)setUp {
  [super setUp];
  self.testCoalescer = [[BCCoalesce alloc] init];
  //    self.performer = [[CallBackPerformer alloc] init];
}

- (void)tearDown {
  [super tearDown];
  self.testCoalescer = nil;
  self.performer = nil;
}

- (void)addThingToTheOtherThing
{
  
}

- (void)testThatThePerformanceBlockIsOnlyCalledOnce {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"callBacksFired"];
  __block NSNumber *callBacksFired = @0;
  __block NSNumber *requestsPerformed = @0;
  
  __weak typeof(self) weakSelf = self;
  
  for (NSInteger i = 0; i < 2; i++) {
    [self.testCoalescer addCallbacksWithProgress:^(CGFloat percent) {
      
    } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
      callBacksFired = @(callBacksFired.integerValue+1);
      if (callBacksFired.integerValue > 1) {
        [expectation fulfill];
      }
    } forIdentifier:@"test" withRequestPerformanceBlock:^{
      requestsPerformed = @(requestsPerformed.integerValue+1);
      if (requestsPerformed.intValue == 2) {
        _XCTPrimitiveFail(weakSelf, @"requests called multiple times.");
      }
      weakSelf.performer = [[CallBackPerformer alloc] initWithProgress:^{
        [weakSelf.testCoalescer identifier:@"test" progressed:0.5];
      } completion:^{
        [weakSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
      }];
      [weakSelf.performer execute];
    }];
  }
  
  [self waitForExpectationsWithTimeout:4.0 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

- (void)testThatTheInterpolationBlockIsPerformed {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"callBacksFired"];
  __block NSNumber *callBacksFired = @0;
  __block NSNumber *requestsPerformed = @0;
  
  __weak typeof(self) weakSelf = self;
  
  for (NSInteger i = 0; i < 2; i++) {
    [self.testCoalescer addCallbacksWithProgress:^(CGFloat percent) {
      
    } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
      callBacksFired = @(callBacksFired.integerValue+1);
      if (callBacksFired.integerValue > 1) {
        [expectation fulfill];
      }
    } forIdentifier:@"test" withRequestPerformanceBlock:^{
      requestsPerformed = @(requestsPerformed.integerValue+1);
      if (requestsPerformed.intValue == 2) {
        _XCTPrimitiveFail(weakSelf, @"requests called multiple times.");
      }
      weakSelf.performer = [[CallBackPerformer alloc] initWithProgress:^{
        [weakSelf.testCoalescer identifier:@"test" progressed:0.5];
      } completion:^{
        [weakSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
      }];
      [weakSelf.performer execute];
    }];
  }
  
  [self waitForExpectationsWithTimeout:4.0 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

@end
