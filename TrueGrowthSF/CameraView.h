//
//  UIViewController+CameraView.h
//  TrueGrowthSF
//
//  Created by elliott chavis on 3/5/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraView : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

- (IBAction)addPhotoClicked:(id)sender;
- (IBAction)uploadPhotoClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end
