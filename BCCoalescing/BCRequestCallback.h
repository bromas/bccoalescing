//
//  BCRequestCallback.h
//  BCCoalescingSample
//
//  Created by Brian Thomas on 2/11/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCCoalesce.h"

@interface BCRequestCallback : NSObject

@property (nonatomic, copy) BCProgressBlock progress;
@property (nonatomic, copy) BCCompletionBlock completion;

+ (instancetype)callBackWithProgress:(BCProgressBlock)progressBlock andCompletion:(BCCompletionBlock)completionBlock;

@end
