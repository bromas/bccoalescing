//
//  BCTestCallBacks.h
//  BCCoalescingSample
//
//  Created by Brian Thomas on 4/24/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCTestCallBacks : NSObject

@property (nonatomic, copy) void (^progress)(CGFloat);
@property (nonatomic, copy) void (^completion)(void);

- (instancetype)initWithProgress:(void (^)(CGFloat))progressBlock completion:(void (^)(void))completionBlock;
- (void)execute;

@end
