//
//  EditProfileViewController.m
//  TrueGrowthSF
//
//  Created by Johny Babylon on 2/5/17.
//  Copyright © 2017 Agile Associates. All rights reserved.
//

#import "EditProfileViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import <AWSS3/AWSS3TransferManager.h>
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>


@interface EditProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@end

@implementation EditProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.uploadButton.enabled = NO;
    self.uploadButton.alpha = 0.5;
    
    //[self performSelectorOnMainThread:@selector(makeMyProgressBarMoving) withObject:nil waitUntilDone:NO];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
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
    
    //   http://stackoverflow.com/questions/4314405/how-can-i-get-the-name-of-image-picked-through-photo-library-in-iphone
    // get the ref url
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        NSString *photoName = [imageRep filename];
        
        [[NSUserDefaults standardUserDefaults] setObject:photoName forKey:@"photoName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        // Initialize CoreData and save filename
        //NSManagedObjectContext *context = [self managedObjectContext];
        //NSManagedObject *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"UploadedPhoto" inManagedObjectContext:context];
        //[newPhoto setValue:photoName forKey:@"name"];
        
        if (self.pictureView.image != nil){
            self.uploadButton.enabled = YES;
            self.uploadButton.alpha = 1;
        }
        
        
    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    
    
}





- (IBAction)choosePhotoClicked:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
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
    self.threadProgressView.hidden = NO;
    
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    
    
    UIImage *image = self.pictureView.image;
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    //convert uiimage to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    NSString *user_profile = [[NSUserDefaults standardUserDefaults] stringForKey:@"userProfile"];
    NSString *url_suffix = key;
    
    // Upload to AWS
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"truegrowthsf/profiles";
    uploadRequest.key = key;
    uploadRequest.body = fileUrl;
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.ACL = AWSS3BucketCannedACLPublicRead;
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.threadProgressView.progress = (float)totalBytesSent/(float)totalBytesExpectedToSend;
            //[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(makeMyProgressBarMoving) userInfo:nil repeats:NO];
        });
    };
    
    
    
    
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
                                                               
                                                               AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                                                               
                                                               AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
                                                               policy.allowInvalidCertificates = YES;
                                                               manager.securityPolicy = policy;
                                                               
                                                               manager.requestSerializer = [AFJSONRequestSerializer serializer];
                                                               
                                                               [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                                                               
                                                               NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                                               params[@"id"] = user_id;
                                                               params[@"url"] = url_suffix;
                                                               params[@"user_profile"] = user_profile;
                                                               
                                                               [manager POST:@"https://true-growth-api.herokuapp.com/api/users/profile" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                                                                   
                                                                   if ( responseObject[@"errors"] == NULL){
                                                                       
                                                                       
                                                                       //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
                                                                       
                                                                       NSString *url_prefix = @"https://s3-us-west-1.amazonaws.com/truegrowthsf/profiles/";
                                                                       NSString *string3 = [url_prefix stringByAppendingString:url_suffix];
                                                                       [[NSUserDefaults standardUserDefaults] setObject:string3 forKey:@"userProfile"];
                                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                                       NSLog(@"string 3 %@", string3);
                                                                       NSLog(@"again string 3 %@", string3);



                                                                       
                                                                       [self performSegueWithIdentifier:@"exitAfterProfileUpload" sender:self];
                                                                       
                                                                       
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
                                                           return nil;
                                                       }];
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    
    
    
    
    
    
    
}


@end
