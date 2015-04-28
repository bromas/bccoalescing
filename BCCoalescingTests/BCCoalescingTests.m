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
#import "BCTestCallBacks.h"

@interface BCCoalescingTests : XCTestCase

@property (nonatomic, strong) BCCoalesce *testCoalescer;
@property (nonatomic, strong) BCTestCallBacks *performer;
@property (nonatomic, strong) BCRegistrationToken *registrationToken;
@property (nonatomic) BOOL unregistered;

@end

@implementation BCCoalescingTests

- (void)setUp {
  [super setUp];
  self.testCoalescer = [[BCCoalesce alloc] init];
  self.unregistered = NO;
}

- (void)tearDown {
  [super tearDown];
  self.testCoalescer = nil;
  self.performer = nil;
}

- (void)unregisterStoredToken {
  [self.registrationToken invalidate];
  self.unregistered = YES;
}

- (void)fullfillExpectation:(XCTestExpectation *)expectation {
  [expectation fulfill];
}

- (void)testThatThePerformanceBlockIsOnlyCalledOnceButTheCompletionIsCalledForEachObserver {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"callBacksFired"];
  __block NSNumber *callBacksFired = @0;
  __block NSNumber *requestsPerformed = @0;
  
  __weak typeof(self) weakSelf = self;
  
  for (NSInteger i = 0; i < 2; i++) {
    [self.testCoalescer addCallbackWithProgress:^(CGFloat percent) {
      
    } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
      
      callBacksFired = @(callBacksFired.integerValue+1);
      if (callBacksFired.integerValue > 1) {
        [expectation fulfill];
      }
      
    } forIdentifier:@"test" withRequestPerformanceBlock:^{
      
      __strong typeof(self) strongSelf = weakSelf;
      requestsPerformed = @(requestsPerformed.integerValue+1);
      
      if (requestsPerformed.intValue == 2) {
        _XCTPrimitiveFail(weakSelf, @"requests called multiple times.");
      }
      
      strongSelf.performer = [[BCTestCallBacks alloc] initWithProgress:^(CGFloat progress){
        [strongSelf.testCoalescer identifier:@"test" progressed:progress];
      } completion:^{
        [strongSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
      }];
      [strongSelf.performer execute];
    }];
    
  }
  
  [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
    NSLog(@"Done waiting.");
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}


- (void)testThatTheInterpolationBlockIsPerformedOnceForMultipleObservers {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"interpolationCalledOnce"];
  __block NSNumber *callBacksFired = @0;
  __block NSNumber *interpolationsPerformed = @0;
  
  __weak typeof(self) weakSelf = self;
  
  self.testCoalescer.resultsInterpolator = ^NSString*(id data) {
    interpolationsPerformed = @(interpolationsPerformed.integerValue+1);
    if (interpolationsPerformed.intValue == 2) {
      _XCTPrimitiveFail(weakSelf, @"requests called multiple times.");
    }
    return @"interpolated";
  };
  
  for (NSInteger i = 0; i < 2; i++) {
    [self.testCoalescer addCallbackWithProgress:^(CGFloat percent) {
      
    } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
      
      callBacksFired = @(callBacksFired.integerValue+1);
      if (callBacksFired.integerValue > 1 && [(NSString*)result isEqualToString:@"interpolated"]) {
        [expectation fulfill];
      }
      
    } forIdentifier:@"test" withRequestPerformanceBlock:^{
      
      weakSelf.performer = [[BCTestCallBacks alloc] initWithProgress:^(CGFloat progress){
        [weakSelf.testCoalescer identifier:@"test" progressed:progress];
      } completion:^{
        [weakSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
      }];
      [weakSelf.performer execute];
    }];
    
  }
  
  [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

- (void)testThatCallbacksCanBeUnregisteredAndThenWontExecute {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"unregistration"];
  
  __weak typeof(self) weakSelf = self;
  
  self.registrationToken = [self.testCoalescer addCallbackWithProgress:^(CGFloat percent) {
    if (weakSelf.unregistered) {
      _XCTPrimitiveFail(weakSelf, @"progress should not take place after unregistering.");
    }
  } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
    _XCTPrimitiveFail(weakSelf, @"completion should not be reached.");
  } forIdentifier:@"test" withRequestPerformanceBlock:^{
    
    weakSelf.performer = [[BCTestCallBacks alloc] initWithProgress:^(CGFloat progress){
      [weakSelf.testCoalescer identifier:@"test" progressed:progress];
    } completion:^{
      [weakSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
    }];
    [weakSelf.performer execute];
  }];
  
  [self performSelector:@selector(unregisterStoredToken) withObject:nil afterDelay:1];
  [self performSelector:@selector(fullfillExpectation:) withObject:expectation afterDelay:7];
  
  [self waitForExpectationsWithTimeout:8.0 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

- (void)testThatCallbacksCanBeUnregisteredAndTheUnregisterBlockExecutes {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"unregistration"];
  
  __weak typeof(self) weakSelf = self;
  
  [self.testCoalescer setUnregisteredBlock:^(NSString *identifier) {
    [expectation fulfill];
  }];
  
  self.registrationToken = [self.testCoalescer addCallbackWithProgress:^(CGFloat percent) {
    
  } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
    _XCTPrimitiveFail(weakSelf, @"completion should not be reached.");
  } forIdentifier:@"test" withRequestPerformanceBlock:^{
    
    weakSelf.performer = [[BCTestCallBacks alloc] initWithProgress:^(CGFloat progress){
      [weakSelf.testCoalescer identifier:@"test" progressed:progress];
    } completion:^{
      [weakSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
    }];
    [weakSelf.performer execute];
  }];
  
  [self performSelector:@selector(unregisterStoredToken) withObject:nil afterDelay:1];
  
  [self waitForExpectationsWithTimeout:8.0 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

- (void)testThatUnregisteredBlockDoesNotExecuteIfObserversExistAfterUnregistration {
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"unregistration"];
  
  __weak typeof(self) weakSelf = self;
  
  [self.testCoalescer setUnregisteredBlock:^(NSString *identifier) {
    _XCTPrimitiveFail(weakSelf, @"completion should not be reached.");
  }];
  
//  make 2 observers and unregister one of them
  for (NSInteger i = 0; i < 2; i++) {
    self.registrationToken = [self.testCoalescer addCallbackWithProgress:^(CGFloat percent) {
      
    } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
      [expectation fulfill];
    } forIdentifier:@"test" withRequestPerformanceBlock:^{
      
      weakSelf.performer = [[BCTestCallBacks alloc] initWithProgress:^(CGFloat progress){
        [weakSelf.testCoalescer identifier:@"test" progressed:progress];
      } completion:^{
        [weakSelf.testCoalescer identifier:@"test" completedWithData:nil andError:nil];
      }];
      [weakSelf.performer execute];
    }];
  }
  
  [self performSelector:@selector(unregisterStoredToken) withObject:nil afterDelay:1];
  
  [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

@end
