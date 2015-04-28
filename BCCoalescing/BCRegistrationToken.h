//
//  BCRegistrationToken.h
//  BCCoalescingSample
//
//  Created by Brian Thomas on 4/22/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCRequestCallback.h"

@interface BCRegistrationToken : NSObject

- (instancetype)initWithCoalescer:(BCCoalesce *)coalescer identifier:(NSString *)identifier andCallBack:(BCRequestCallback *)callBack;

- (void)invalidate;

@end
