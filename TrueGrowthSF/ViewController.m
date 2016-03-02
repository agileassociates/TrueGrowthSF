//
//  ViewController.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/18/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signinClicked:(id)sender {
    
    if([[self.emailTextField text] isEqualToString:@""] || [[self.passwordTextField text] isEqualToString:@""] ) {
        
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                        message:@"Please enter Email & Password"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                    [alert show];

        
            }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"email"] = email;
    params[@"password"] = password;
    
    [manager POST:@"https://localhost:9292/api/sessions" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ( responseObject[@"errors"] == NULL){
        
        
        //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
            NSLog(@"%@", responseObject);
            
            if ([responseObject isKindOfClass:[NSArray class]]) {          // i used this to find out responseobj type!!
                
                NSLog(@"Array");
                
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSLog(@"Dictionary");
                
            };
        
        [self performSegueWithIdentifier:@"login_success" sender:self];
            
        } else {
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Info"
                                          message:responseObject[@"errors"]
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
            
            NSLog(@"JSON: %@", responseObject[@"errors"]);

            
        }

        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"error = %@", error);
        
    }];


    
    
}


- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
