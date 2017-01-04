//
//  SignInViewController.m
//  TrueGrowthSF
//
//  Created by Johny Babylon on 1/1/17.
//  Copyright © 2017 Agile Associates. All rights reserved.
//

#import "SignInViewController.h"
#import "AFNetworking.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitButtonClicked:(id)sender {
    
        
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *confirmation = _confirmationTextField.text;
    
    
    NSDictionary *params = [[NSDictionary alloc] init];
    //params = @{@"email":email, @"password":password, @"password_confirmation":confirmation};
    params = @{@"user": @{@"email":email, @"password":password, @"password_confirmarion":confirmation}};

    
    [manager POST:@"https://true-growth-api.herokuapp.com/api/users" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
      
        
        if ( responseObject[@"errors"] == NULL){
            
            NSLog(@"responseObject: %@", responseObject);
            
            NSString *user_id = responseObject[@"data"][@"id"];
            NSLog(@" user id is %@", user_id);
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ( responseObject[@"data"][@"attributes"][@"user_profile"]  == (id)[NSNull null]){
                NSString *user_profile = @"empty";
                NSLog(@" user profile 1 is %@", user_profile);
                [[NSUserDefaults standardUserDefaults] setObject:user_profile forKey:@"userProfile"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
            NSString *user_profile = responseObject[@"data"][@"attributes"][@"user_profile"];
            NSLog(@" user profile 2 is %@", user_profile);
            [[NSUserDefaults standardUserDefaults] setObject:user_profile forKey:@"userProfile"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            }
            

            
            [self performSegueWithIdentifier:@"sign_up_success" sender:self];
            

            
        } else {
            
            if ([responseObject isKindOfClass:[NSArray class]]) {          // i used this to find out responseobj type!!
                
                NSLog(@"Array");
                
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSLog(@"Dictionary");
                
            };
            NSString *responseString = [NSString stringWithFormat:@"Error %@", responseObject];
            
                        UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Info"
                                          //message:responseObject[@"errors"]
                                          message:responseString
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"JSON errors: %@", responseObject);
            
            
        }
        
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"error = %@", error);
        
    }];


}
@end
