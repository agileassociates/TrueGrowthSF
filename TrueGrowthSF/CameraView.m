//
//  UIViewController+CameraView.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 3/5/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "CameraView.h"

@interface CameraView () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation CameraView

- (void)viewDidAppear:(BOOL)animated {
    //[super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    // If the device has a camera, take a picture, otherwise,
    // just pick from photo library
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:NULL];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
