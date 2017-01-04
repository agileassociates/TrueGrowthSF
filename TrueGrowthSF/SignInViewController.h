//
//  SignInViewController.h
//  TrueGrowthSF
//
//  Created by Johny Babylon on 1/1/17.
//  Copyright © 2017 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

@property(weak, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic) IBOutlet UITextField *confirmationTextField;

-(IBAction)submitButtonClicked:(id)sender;

@end

