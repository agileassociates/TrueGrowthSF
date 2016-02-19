//
//  ViewController.h
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/18/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signinClicked:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end

