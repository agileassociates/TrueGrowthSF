//
//  EditViewController.m
//  TrueGrowthSF
//
//  Created by Johny Babylon on 1/10/17.
//  Copyright © 2017 Agile Associates. All rights reserved.
//

#import "EditViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import <AWSS3/AWSS3TransferManager.h>
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>


@interface EditViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up label & image view
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:200];
    
    // Get user profile from userDefaults
    NSString *user_profile = [[NSUserDefaults standardUserDefaults] stringForKey:@"userProfile"];

    if ([user_profile isEqual: @"not null"]){
        label.text = @"add photo";
        label.layer.masksToBounds = true;
        label.layer.cornerRadius = 8.0;
    }else{
        [label setHidden:YES];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^ (void) {
            
            
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_profile]];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    imageView.image = image;
                    //[cell setNeedsDisplay];
                });
            }
        });

        
    };
    


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

@end
