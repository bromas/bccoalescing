//
//  ViewController.m
//  BCCoalescingSample
//
//  Created by Brian Thomas on 2/11/15.
//  Copyright (c) 2015 Brian Thomas. All rights reserved.
//

#import "ViewController.h"
@import BCCoalescing;

@interface ViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) BCCoalesce *imageCoalescer;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    _imageCoalescer = [[BCCoalesce alloc] init];
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  __weak ViewController *weakself = self;
  
  [self.imageCoalescer addCallbackWithProgress:^(CGFloat percent) {
    
  } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
    
  } forIdentifier:@"wat" withRequestPerformanceBlock:^{
    [weakself.session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      [weakself.imageCoalescer identifier:@"wat" completedWithData:data response:response andError:error];
    }];
  }];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
