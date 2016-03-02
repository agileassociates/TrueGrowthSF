//
//  UIViewController+NewsController.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/20/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "NewsController.h"
#import "AFNetworking.h"
#import "NSString+URLEncoding.h"

@interface NewsController ()

@end

@implementation NewsController

- (void)viewWillAppear:(BOOL)animated {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    
    manager.securityPolicy = policy;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager GET:@"https://127.0.0.1:9292/api/posts" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSInteger j = 0;
        
        for ( j =0; j<2; j++)
        {
            NSLog(@"JSON: %@", responseObject[@"data"][j][@"attributes"][@"url"]);
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"error = %@", error);
        
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

}


@end