//
//  NewCameraView.h
//  TrueGrowthSF
//
//  Created by Johny Babylon on 10/17/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCameraView : UIViewController

{
    NSMutableData *_responseData;

}

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic)IBOutlet UIButton *uploadButton;
@property (weak, nonatomic)IBOutlet UIProgressView * threadProgressView;


- (IBAction)choosePhotoClicked:(id)sender;
- (IBAction)uploadPhotoClicked:(id)sender;



@end
