//
//  ViewController.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/18/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreData/CoreData.h>



@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    
    //loginButton.center = self.view.center;
    
    loginButton.frame = CGRectMake(20, 310, 280, 37);

    
    [self.view addSubview:loginButton];
    
    }

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}




- (void)viewDidAppear:(BOOL)animated {
    
   
       if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        [self performSegueWithIdentifier:@"facebook_login" sender:self];
        
    }
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
         if (!error) {
             NSLog(@"fetched user:%@  and name : %@  and ID : %@", result,result[@"name"],result[@"id"]);
             
             AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
             
             AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
             policy.allowInvalidCertificates = YES;
             manager.securityPolicy = policy;
             
             manager.requestSerializer = [AFJSONRequestSerializer serializer];
             
             [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
             
             NSString *facebook_email;
             if (!result[@"email"]){
               facebook_email = result[@"name"];
                 [[NSUserDefaults standardUserDefaults] setObject:result[@"name"] forKey:@"userId"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
             } else {
               facebook_email = result[@"email"];
                 [[NSUserDefaults standardUserDefaults] setObject:result[@"email"] forKey:@"userId"];
                 [[NSUserDefaults standardUserDefaults] synchronize];

             }
             NSString *facebook_id = result[@"id"];
             
             NSDictionary *params = [[NSMutableDictionary alloc] init];
             params = @{@"book": @{@"email":facebook_email, @"id":facebook_id}};

             
             [manager POST:@"https://true-growth-api.herokuapp.com/api/books/show" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                 
                 if ( responseObject[@"errors"] == NULL){
                     NSLog(@"%@", responseObject);
                 }else{
                     
                 }
             }failure:^(NSURLSessionTask *operation, NSError *error) {
                 
                 NSLog(@"error = %@", error);
                 
             }];

            


             
         }
              
     }];
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
    
    [manager POST:@"https://true-growth-api.herokuapp.com/api/sessions" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ( responseObject[@"errors"] == NULL){
        
        
        //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
            NSLog(@"%@", responseObject);
            
            if ([responseObject isKindOfClass:[NSArray class]]) {          // i used this to find out responseobj type!!
                
                NSLog(@"Array");
                
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSLog(@"Dictionary");
                
            };
            
            NSLog(@"responseObject: %@", responseObject);
            
            NSString *user_id = responseObject[@"data"][@"id"];
            NSLog(@" user id is %@", user_id);
            NSString *favorites = responseObject[@"data"][@"attributes"][@"favorites"];
            NSLog(@" favorites is %@", favorites);
            
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"favorites"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ( responseObject[@"data"][@"attributes"][@"user_profile"] == (id)[NSNull null]){
                NSString *user_profile = @"empty";
                NSLog(@" user profile is %@", user_profile);
                [[NSUserDefaults standardUserDefaults] setObject:user_profile forKey:@"userProfile"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                NSString *user_profile = responseObject[@"data"][@"attributes"][@"user_profile"];
                NSLog(@" user profile is %@", user_profile);
                [[NSUserDefaults standardUserDefaults] setObject:user_profile forKey:@"userProfile"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            
        
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
