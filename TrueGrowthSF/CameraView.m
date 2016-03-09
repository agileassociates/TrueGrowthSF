//
//  UIViewController+CameraView.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 3/5/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "CameraView.h"
#import "AFNetworking.h"
#import <AWSS3/AWSS3TransferManager.h>
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>

@interface CameraView () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation CameraView

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Put that image onto the screen in our image view
    self.pictureView.image = image;
    
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addPhotoClicked:(id)sender {
    
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

- (IBAction)uploadPhotoClicked:(id)sender {
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    UIImage *image = self.pictureView.image;
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    //convert uiimage to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"truegrowthsf";
    uploadRequest.key = key;
    uploadRequest.body = fileUrl;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                           }
                                                           return nil;
                                                       }];


    
    }

@end
