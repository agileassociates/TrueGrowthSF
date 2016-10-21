//
//  CameraButtonView.h
//  TrueGrowthSF
//
//  Created by Johny Babylon on 10/17/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraButtonView : UIView <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;


- (IBAction)choosePhotoClicked:(id)sender;


@end
