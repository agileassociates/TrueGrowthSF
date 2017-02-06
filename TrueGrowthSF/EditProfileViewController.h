//
//  EditProfileViewController.h
//  TrueGrowthSF
//
//  Created by Johny Babylon on 2/5/17.
//  Copyright © 2017 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController
{
    NSMutableData *_responseData;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic)IBOutlet UIButton *uploadButton;
@property (weak, nonatomic)IBOutlet UIProgressView * threadProgressView;


- (IBAction)choosePhotoClicked:(id)sender;
- (IBAction)uploadPhotoClicked:(id)sender;



@end
